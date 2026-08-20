param(
    [string]$GodotPath = 'C:\_projekty\Godot_v4.7-stable_win64.exe',
    [string]$AabPath = '',
    [string]$ToolRoot = '',
    [string]$KeystorePath = $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH,
    [string]$KeyAlias = $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
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

if (-not $javaHome -or -not $buildToolsDirectory -or -not (Test-Path -LiteralPath $jarsignerPath) -or -not (Test-Path -LiteralPath $jarPath)) {
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

$presetPath = Join-Path $projectRoot 'export_presets.cfg'
$presetLines = @(Get-Content -LiteralPath $presetPath)
$presetText = $presetLines -join "`n"
$excludeFilters = @($presetLines | Where-Object { $_.StartsWith('exclude_filter=', [System.StringComparison]::Ordinal) })
if ($presetText -notmatch '(?m)^name="Android Release AAB"$' -or
    $presetText -notmatch '(?m)^gradle_build/export_format=1$' -or
    $presetText -notmatch '(?m)^gradle_build/target_sdk="36"$') {
    throw 'Android Release AAB preset is missing, is not an AAB, or does not pin target SDK 36.'
}
if ($excludeFilters.Count -ne 2 -or $excludeFilters[0] -cne $excludeFilters[1]) {
    throw 'Debug APK and release AAB export filters have drifted.'
}
if ($presetText -match '(?m)^keystore/release_password=".+"$') {
    throw 'Release password must not be stored in export_presets.cfg.'
}

$configGradleText = Get-Content -LiteralPath (Join-Path $projectRoot 'android\build\config.gradle') -Raw
$targetSdkMatch = [regex]::Match($configGradleText, '(?m)^\s*targetSdk\s*:\s*(\d+)\s*,?\s*$')
if (-not $targetSdkMatch.Success -or [int]$targetSdkMatch.Groups[1].Value -lt 36) {
    throw 'Godot Android build template does not target API level 36 or newer.'
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
$reportPath = Join-Path $evidenceRoot 'report.md'

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
$output = if (Test-Path -LiteralPath $logPath) { Get-Content -LiteralPath $logPath -Raw } else { '' }
Write-Output $output
if ($process.ExitCode -ne 0 -or $output -match 'Project export.*failed|Cannot export project' -or -not (Test-Path -LiteralPath $resolvedAabPath -PathType Leaf)) {
    throw "Android release AAB export failed with native exit code $($process.ExitCode)."
}
Write-Output 'GODOT_RELEASE_AAB_EXPORT=PASSED'

$jarsignerOutput = @(& $jarsignerPath -verify -certs $resolvedAabPath 2>&1)
[System.IO.File]::WriteAllLines($jarsignerLogPath, [string[]]$jarsignerOutput, [System.Text.UTF8Encoding]::new($false))
$jarsignerText = $jarsignerOutput -join "`n"
if ($LASTEXITCODE -ne 0 -or $jarsignerText -notmatch '(?m)^jar verified\.\s*$') {
    throw 'AAB JAR signature verification failed.'
}
Write-Output 'AAB_SIGNATURE_CHECK=PASSED'

$aabEntries = @(& $jarPath tf $resolvedAabPath)
if ($LASTEXITCODE -ne 0) {
    throw 'Could not inspect the AAB payload.'
}
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

$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $resolvedAabPath
$sizeBytes = (Get-Item -LiteralPath $resolvedAabPath).Length
$sizeMiB = [Math]::Round($sizeBytes / 1MB, 2)
$report = @(
    "# Bazal’s Pocket Garden release AAB evidence",
    '',
    "- UTC run: $timestamp",
    '- Preset: Android Release AAB',
    '- Package: com.howtogrow.game',
    '- Version: 0.45.0-rc29 (46)',
    '- Target SDK: 36',
    '- Architecture: arm64-v8a',
    "- AAB: $resolvedAabPath",
    "- Size: $sizeBytes bytes ($sizeMiB MiB)",
    "- SHA-256: $($hash.Hash)",
    '- GODOT_RELEASE_AAB_EXPORT=PASSED',
    '- AAB_SIGNATURE_CHECK=PASSED',
    '- AAB_PAYLOAD_CHECK=PASSED',
    '- AAB_NOTIFICATION_PAYLOAD_CHECK=PASSED',
    '',
    'This proves the local AAB pipeline only. Play Console review and production upload-key custody remain pending.'
)
[System.IO.File]::WriteAllLines($reportPath, $report, [System.Text.UTF8Encoding]::new($false))
Write-Output "AAB_READY=$resolvedAabPath"
Write-Output "AAB_SIZE_MIB=$sizeMiB"
Write-Output "SHA256=$($hash.Hash)"
Write-Output "AAB_EVIDENCE=$evidenceRoot"
Write-Output 'ANDROID_RELEASE_AAB_PIPELINE=PASSED'
