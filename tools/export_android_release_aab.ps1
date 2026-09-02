param(
    [string]$GodotPath = '',
    [string]$AabPath = '',
    [string]$ToolRoot = '',
    [string]$KeystorePath = $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH,
    [string]$KeyAlias = $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER,
    [string]$ExpectedSignerSha256 = $env:GODOT_ANDROID_EXPECTED_SIGNER_SHA256,
    [switch]$ValidateConfigurationOnly
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
. (Join-Path $PSScriptRoot 'resolve_godot_executable.ps1')
$GodotPath = Resolve-HowToGrowGodotExecutable -ExplicitPath $GodotPath -ProjectRoot $projectRoot
. (Join-Path $PSScriptRoot 'android_export_contract.ps1')
$releasePreset = Assert-AndroidPresetSetContract -ProjectRoot $projectRoot -PresetName 'Android Release AAB'
if ($releasePreset.ExportFormat -ne 1) {
    throw 'Android Release AAB preset must use the AAB export format.'
}
$configGradleText = Get-Content -LiteralPath (Join-Path $projectRoot 'android\build\config.gradle') -Raw
$targetSdkMatch = [regex]::Match($configGradleText, '(?m)^\s*targetSdk\s*:\s*(\d+)\s*,?\s*$')
if (-not $targetSdkMatch.Success -or [int]$targetSdkMatch.Groups[1].Value -ne $releasePreset.TargetSdk) {
    throw 'Godot Android build template target SDK has drifted from the release preset.'
}
Write-Output 'ANDROID_RELEASE_SOURCE_CONTRACT=PASSED'
if ($ValidateConfigurationOnly) {
    Write-Output "ANDROID_RELEASE_PACKAGE=$($releasePreset.PackageName)"
    Write-Output "ANDROID_RELEASE_VERSION=$($releasePreset.VersionName)"
    Write-Output "ANDROID_RELEASE_VERSION_CODE=$($releasePreset.VersionCode)"
    Write-Output "ANDROID_RELEASE_TARGET_SDK=$($releasePreset.TargetSdk)"
    Write-Output 'ANDROID_RELEASE_CONFIGURATION_ONLY=PASSED'
    return
}
$toolRoot = if ([string]::IsNullOrWhiteSpace($ToolRoot)) {
    Join-Path $projectRoot '.tooling'
} else {
    [System.IO.Path]::GetFullPath($ToolRoot)
}
$javaRoot = Join-Path $toolRoot 'jdk'
$androidSdkRoot = Join-Path $toolRoot 'android-sdk'
$javaHome = Get-ChildItem -LiteralPath $javaRoot -Directory | Select-Object -First 1 -ExpandProperty FullName
$buildToolsDirectory = Get-ChildItem -LiteralPath (Join-Path $androidSdkRoot 'build-tools') -Directory |
    Sort-Object { [version]$_.Name } -Descending |
    Select-Object -First 1
$jarsignerPath = if ($javaHome) { Join-Path $javaHome 'bin\jarsigner.exe' } else { '' }
$jarPath = if ($javaHome) { Join-Path $javaHome 'bin\jar.exe' } else { '' }
$keytoolPath = if ($javaHome) { Join-Path $javaHome 'bin\keytool.exe' } else { '' }

if (-not $javaHome -or -not $buildToolsDirectory -or -not (Test-Path -LiteralPath $jarsignerPath) -or -not (Test-Path -LiteralPath $jarPath) -or -not (Test-Path -LiteralPath $keytoolPath)) {
    throw 'Portable Android release toolchain is missing. See README.md for setup details.'
}
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "Godot executable was not found: $GodotPath"
}
if ([string]::IsNullOrWhiteSpace($KeystorePath) -or -not (Test-Path -LiteralPath $KeystorePath -PathType Leaf)) {
    throw 'Release keystore is missing. Set GODOT_ANDROID_KEYSTORE_RELEASE_PATH or pass -KeystorePath.'
}
if ([string]::IsNullOrWhiteSpace($KeyAlias)) {
    throw 'Release key alias is missing. Set GODOT_ANDROID_KEYSTORE_RELEASE_USER or pass -KeyAlias.'
}
if ([string]::IsNullOrWhiteSpace($env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD)) {
    throw 'Release password is missing. Set GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD in the launch environment; never pass it on the command line.'
}
$normalizedExpectedSignerSha256 = ($ExpectedSignerSha256 -replace '[^0-9A-Fa-f]', '').ToUpperInvariant()
if ($normalizedExpectedSignerSha256.Length -ne 64) {
    throw 'Expected upload signer certificate SHA-256 is missing or malformed. Set GODOT_ANDROID_EXPECTED_SIGNER_SHA256 or pass -ExpectedSignerSha256; a valid signature alone is not sufficient.'
}

$outputDirectory = Join-Path $projectRoot 'builds\android'
$defaultAabPath = Join-Path $outputDirectory 'bazals-pocket-garden-release.aab'
$resolvedAabPath = [System.IO.Path]::GetFullPath($(if ([string]::IsNullOrWhiteSpace($AabPath)) { $defaultAabPath } else { $AabPath }))
if (-not $resolvedAabPath.EndsWith('.aab', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Release output must use the .aab extension.'
}
if (Test-Path -LiteralPath $resolvedAabPath) {
    throw "Refusing to overwrite an existing AAB: $resolvedAabPath"
}
$resolvedAabDirectory = Split-Path -Parent $resolvedAabPath
if (-not (Test-Path -LiteralPath $resolvedAabDirectory)) {
    [System.IO.Directory]::CreateDirectory($resolvedAabDirectory) | Out-Null
}

$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$evidenceRoot = Join-Path $projectRoot ".godot\android-release-aab\$timestamp"
[System.IO.Directory]::CreateDirectory($evidenceRoot) | Out-Null
$logPath = Join-Path $evidenceRoot 'godot-export.log'
$jarsignerLogPath = Join-Path $evidenceRoot 'jarsigner.txt'
$signerFingerprintPath = Join-Path $evidenceRoot 'signer-certificate-sha256.txt'
$reportPath = Join-Path $evidenceRoot 'report.md'
$isolatedAppData = Join-Path $evidenceRoot 'appdata'
[System.IO.Directory]::CreateDirectory($isolatedAppData) | Out-Null

$env:JAVA_HOME = $javaHome
$env:ANDROID_HOME = $androidSdkRoot
$env:ANDROID_SDK_ROOT = $androidSdkRoot
$env:GRADLE_USER_HOME = Join-Path $toolRoot 'gradle-home'
$env:PATH = "$javaHome\bin;$env:PATH"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = [System.IO.Path]::GetFullPath($KeystorePath)
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $KeyAlias
$quotedPresetArgument = '"Android Release AAB"'
$quotedAabArgument = '"' + $resolvedAabPath.Replace('\','/') + '"'
$quotedLogArgument = '"' + $logPath.Replace('\','/') + '"'
$godotArguments = @(
    '--headless',
    '--path', '.',
    '--export-release', $quotedPresetArgument, $quotedAabArgument,
    '--log-file', $quotedLogArgument
)

Write-Output 'ANDROID_RELEASE_AAB_EXPORT=STARTED'
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = $isolatedAppData
    $process = Start-Process `
        -FilePath $GodotPath `
        -WorkingDirectory $projectRoot `
        -ArgumentList $godotArguments `
        -PassThru `
        -WindowStyle Hidden
    if (-not $process.WaitForExit(600000)) {
        $process.Kill()
        throw 'Android release AAB export exceeded the 10 minute safety timeout.'
    }
} finally {
    $env:APPDATA = $previousAppData
}
$output = if (Test-Path -LiteralPath $logPath) { Get-Content -LiteralPath $logPath -Raw } else { '' }
Write-Output $output
if ($process.ExitCode -ne 0 -or $output -match 'Project export.*failed|Cannot export project' -or -not (Test-Path -LiteralPath $resolvedAabPath -PathType Leaf)) {
    throw "Android release AAB export failed with native exit code $($process.ExitCode)."
}
Write-Output 'GODOT_RELEASE_AAB_EXPORT=PASSED'

$jarsignerOutput = @(& $jarsignerPath -verify $resolvedAabPath 2>&1)
[System.IO.File]::WriteAllLines($jarsignerLogPath, [string[]]$jarsignerOutput, [System.Text.UTF8Encoding]::new($false))
$jarsignerText = $jarsignerOutput -join "`n"
if ($LASTEXITCODE -ne 0 -or $jarsignerText -notmatch '(?m)^jar verified\.\s*$') {
    throw 'AAB JAR signature verification failed.'
}
Write-Output 'AAB_SIGNATURE_CHECK=PASSED'

$certificateOutput = @(& $keytoolPath '-J-Duser.language=en' '-J-Duser.country=US' -printcert -jarfile $resolvedAabPath 2>&1)
if ($LASTEXITCODE -ne 0) {
    throw 'Could not read the AAB signer certificate.'
}
$certificateText = $certificateOutput -join "`n"
$signerMatch = [regex]::Match($certificateText, '(?im)^\s*SHA256:\s*([0-9A-F:]{64,95})\s*$')
if (-not $signerMatch.Success) {
    throw 'Could not parse the AAB signer certificate SHA-256.'
}
$actualSignerSha256 = ($signerMatch.Groups[1].Value -replace ':', '').ToUpperInvariant()
if ($actualSignerSha256 -cne $normalizedExpectedSignerSha256) {
    throw "AAB signer certificate mismatch. Expected $normalizedExpectedSignerSha256, got $actualSignerSha256"
}
[System.IO.File]::WriteAllText($signerFingerprintPath, "SIGNER_CERTIFICATE_SHA256=$actualSignerSha256`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output 'AAB_SIGNER_IDENTITY_CHECK=PASSED'

$aabEntries = @(& $jarPath tf $resolvedAabPath)
if ($LASTEXITCODE -ne 0) {
    throw 'Could not inspect the AAB payload.'
}
Assert-AndroidArchiveAbiContract -Entries $aabEntries -PresetContract $releasePreset -Format AAB
Write-Output 'AAB_ABI_CHECK=PASSED'
$requiredEntries = @(
    'BundleConfig.pb',
    'base/manifest/AndroidManifest.xml',
    'base/dex/classes.dex',
    'base/lib/arm64-v8a/libgodot_android.so',
    'assetPackInstallTime/manifest/AndroidManifest.xml',
    'assetPackInstallTime/assets/project.binary',
    'assetPackInstallTime/assets/scripts/main.gdc',
    'assetPackInstallTime/assets/scripts/main.gd.remap'
)
foreach ($requiredEntry in $requiredEntries) {
    if ($aabEntries -notcontains $requiredEntry) {
        throw "AAB is missing required bundle entry: $requiredEntry"
    }
}
if ($aabEntries -match '^base/lib/armeabi-v7a/' -or
    $aabEntries -match '^(?:base|assetPackInstallTime)/assets/(?:docs|tests|tools)/' -or
    $aabEntries -match '^(?:base|assetPackInstallTime)/assets/.+\.gd$' -or
    $aabEntries -match 'source_v1|chroma_v1|reference_phase') {
    throw 'AAB contains a forbidden architecture or source-only artifact.'
}
if (-not ($aabEntries | Where-Object { $_ -match '^(?:base|assetPackInstallTime)/assets/\.godot/exported/.+-main\.scn$' })) {
    throw 'AAB is missing the compiled main scene.'
}
Write-Output 'AAB_PAYLOAD_CHECK=PASSED'

$apkAnalyzerRoot = Join-Path $androidSdkRoot 'cmdline-tools\latest'
$apkAnalyzerClasspath = Join-Path $apkAnalyzerRoot 'lib\apkanalyzer-classpath.jar'
$javaPath = Join-Path $javaHome 'bin\java.exe'
if (-not (Test-Path -LiteralPath $apkAnalyzerClasspath) -or -not (Test-Path -LiteralPath $javaPath)) {
    throw 'Android APK analyzer is missing from the portable toolchain.'
}
$apkAnalyzerSystemProperty = "-Dcom.android.sdklib.toolsdir=$(Join-Path $apkAnalyzerRoot 'bin\..')"
$manifestText = (& $javaPath $apkAnalyzerSystemProperty -classpath $apkAnalyzerClasspath com.android.tools.apk.analyzer.ApkAnalyzerCli manifest print $resolvedAabPath) -join "`n"
if ($LASTEXITCODE -ne 0) {
    throw 'Could not inspect the merged AAB Android manifest.'
}
Assert-AndroidMergedManifestContract -ManifestText $manifestText -PresetContract $releasePreset
Write-Output 'AAB_MANIFEST_CONTRACT=PASSED'
$dexPackages = (& $javaPath $apkAnalyzerSystemProperty -classpath $apkAnalyzerClasspath com.android.tools.apk.analyzer.ApkAnalyzerCli dex packages $resolvedAabPath) -join "`n"
if ($LASTEXITCODE -ne 0) {
    throw 'Could not inspect compiled AAB DEX packages.'
}
$requiredDexTokens = @(
    'com.howtogrow.notifications.CareNotificationBridge',
    'captureLaunchIntent',
    'consumeOpenedSlotNumber',
    'isActivityVisible',
    'com.godot.game.GodotApp void onNewIntent'
)
foreach ($token in $requiredDexTokens) {
    if ($dexPackages -notmatch [regex]::Escape($token)) {
        throw "AAB is missing required notification deep-link code: $token"
    }
}
Write-Output 'AAB_NOTIFICATION_PAYLOAD_CHECK=PASSED'
Assert-AndroidDexPrivacyContract -DexPackagesText $dexPackages
Write-Output 'AAB_PRIVACY_SDK_ALLOWLIST=PASSED'

$gradleHome = Join-Path $toolRoot 'gradle-home'
Assert-Aab16KiBAlignment -AabPath $resolvedAabPath -JavaPath $javaPath -GradleHome $gradleHome
Write-Output 'AAB_16K_ALIGNMENT_CHECK=PASSED'

$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $resolvedAabPath
$sizeBytes = (Get-Item -LiteralPath $resolvedAabPath).Length
$sizeMiB = [Math]::Round($sizeBytes / 1MB, 2)
$report = @(
    "# Bazal’s Pocket Garden release AAB evidence",
    '',
    "- UTC run: $timestamp",
    '- Preset: Android Release AAB',
    "- Package: $($releasePreset.PackageName)",
    "- Version: $($releasePreset.VersionName) ($($releasePreset.VersionCode))",
    "- Target SDK: $($releasePreset.TargetSdk)",
    '- Architecture: arm64-v8a',
    "- AAB: $resolvedAabPath",
    "- Size: $sizeBytes bytes ($sizeMiB MiB)",
    "- SHA-256: $($hash.Hash)",
    '- GODOT_RELEASE_AAB_EXPORT=PASSED',
    '- AAB_SIGNATURE_CHECK=PASSED',
    '- AAB_SIGNER_IDENTITY_CHECK=PASSED',
    "- Signer certificate SHA-256: $actualSignerSha256",
    '- AAB_PAYLOAD_CHECK=PASSED',
    '- AAB_ABI_CHECK=PASSED',
    '- AAB_MANIFEST_CONTRACT=PASSED',
    '- AAB_NOTIFICATION_PAYLOAD_CHECK=PASSED',
    '- AAB_PRIVACY_SDK_ALLOWLIST=PASSED',
    '- AAB_16K_ALIGNMENT_CHECK=PASSED',
    '',
    'This proves the local AAB pipeline only. Play Console review and production upload-key custody remain pending.'
)
[System.IO.File]::WriteAllLines($reportPath, $report, [System.Text.UTF8Encoding]::new($false))
Write-Output "AAB_READY=$resolvedAabPath"
Write-Output "AAB_SIZE_MIB=$sizeMiB"
Write-Output "SHA256=$($hash.Hash)"
Write-Output "AAB_EVIDENCE=$evidenceRoot"
Write-Output 'ANDROID_RELEASE_AAB_PIPELINE=PASSED'
