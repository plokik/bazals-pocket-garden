param(
    [string]$GodotPath = '',
    [string]$ApkPath = '',
    [string]$ToolRoot = '',
    [string]$PresetName = 'Android'
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
. (Join-Path $PSScriptRoot 'resolve_godot_executable.ps1')
$GodotPath = Resolve-HowToGrowGodotExecutable -ExplicitPath $GodotPath -ProjectRoot $projectRoot
. (Join-Path $PSScriptRoot 'android_export_contract.ps1')
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
$zipAlignPath = if ($buildToolsDirectory) { Join-Path $buildToolsDirectory.FullName 'zipalign.exe' } else { '' }

if (-not $javaHome -or -not $buildToolsDirectory -or
    -not (Test-Path -LiteralPath (Join-Path $buildToolsDirectory.FullName 'apksigner.bat')) -or
    -not (Test-Path -LiteralPath $zipAlignPath)) {
    throw 'Portable Android toolchain is missing. See README.md for setup details.'
}

$env:JAVA_HOME = $javaHome
$env:ANDROID_HOME = $androidSdkRoot
$env:ANDROID_SDK_ROOT = $androidSdkRoot
$env:GRADLE_USER_HOME = Join-Path $toolRoot 'gradle-home'
$env:PATH = "$javaHome\bin;$env:PATH"
$outputDirectory = Join-Path $projectRoot 'builds\android'
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}
$defaultApkPath = Join-Path $outputDirectory 'bazals-pocket-garden-debug.apk'
$apkPath = if ([string]::IsNullOrWhiteSpace($ApkPath)) { $defaultApkPath } else { $ApkPath }
$apkDirectory = Split-Path -Parent $apkPath
if (-not (Test-Path -LiteralPath $apkDirectory)) {
    New-Item -ItemType Directory -Path $apkDirectory | Out-Null
}
$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$evidenceRoot = Join-Path $projectRoot ".godot\android-export\$timestamp"
[System.IO.Directory]::CreateDirectory($evidenceRoot) | Out-Null
$logPath = Join-Path $evidenceRoot 'godot-export.log'
$logRelative = ".godot/android-export/$timestamp/godot-export.log"
$isolatedAppData = Join-Path $evidenceRoot 'appdata'
[System.IO.Directory]::CreateDirectory($isolatedAppData) | Out-Null
$quotedApkArgument = '"' + $apkPath.Replace('\','/') + '"'
if ($PresetName -notmatch '^[A-Za-z0-9 _-]{1,64}$') {
    throw 'Android export preset name contains unsupported characters.'
}
$presetContract = Assert-AndroidPresetSetContract -ProjectRoot $projectRoot -PresetName $PresetName
if ($presetContract.ExportFormat -ne 0) {
    throw "The APK exporter requires an APK preset: $PresetName"
}
Write-Output 'ANDROID_SOURCE_CONTRACT=PASSED'
$quotedPresetArgument = '"' + $PresetName + '"'

$godotArguments = @(
    '--headless',
    '--path', '.',
    '--export-debug', $quotedPresetArgument, $quotedApkArgument,
    '--log-file', $logRelative
)
Write-Output 'ANDROID_EXPORT=STARTED'
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
        throw 'Android export exceeded the 10 minute safety timeout.'
    }
} finally {
    $env:APPDATA = $previousAppData
}

$output = Get-Content -LiteralPath $logPath -Raw
Write-Output $output
if ($process.ExitCode -ne 0 -or $output -match 'Project export.*failed|Cannot export project') {
    throw "Android export failed with native exit code $($process.ExitCode)."
}
Write-Output 'GODOT_GRADLE_EXPORT=PASSED'
Write-Output "ANDROID_EXPORT_EVIDENCE=$evidenceRoot"

& (Join-Path $buildToolsDirectory.FullName 'apksigner.bat') verify --verbose $apkPath
if ($LASTEXITCODE -ne 0) {
    throw 'APK signature verification failed.'
}
Write-Output 'APK_SIGNATURE_CHECK=PASSED'

$jarPath = Join-Path $javaHome 'bin\jar.exe'
$apkEntries = @(& $jarPath tf $apkPath)
if ($LASTEXITCODE -ne 0) {
    throw 'Could not inspect the APK payload.'
}
Assert-AndroidArchiveAbiContract -Entries $apkEntries -PresetContract $presetContract -Format APK
Write-Output 'APK_ABI_CHECK=PASSED'
Write-Output 'APK_ENTRY_SCAN=PASSED'
$requiredEntries = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$requiredScriptPayloadEntries = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$scriptPayloadBasesGdc = @{} # base => $true
$scriptPayloadBasesRemap = @{} # base => $true
$requiredScriptBases = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$runtimeTextFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
Get-ChildItem -LiteralPath (Join-Path $projectRoot 'scripts') -Recurse -File -Filter '*.gd' | ForEach-Object {
    $runtimeTextFiles.Add($_)
    $relativeScriptPath = $_.FullName.Substring($projectRoot.Length + 1).Replace('\', '/')
    $scriptBase = $relativeScriptPath.Substring(0, $relativeScriptPath.Length - 3)
    [void]$requiredEntries.Add('assets/' + $scriptBase + '.gdc')
    [void]$requiredScriptPayloadEntries.Add('assets/' + $scriptBase + '.gdc')
    [void]$requiredScriptPayloadEntries.Add('assets/' + $scriptBase + '.gd.remap')
    [void]$requiredScriptBases.Add($scriptBase)
}
$runtimeTextFiles.Add((Get-Item -LiteralPath (Join-Path $projectRoot 'main.tscn')))
$runtimeTextFiles.Add((Get-Item -LiteralPath (Join-Path $projectRoot 'startup.tscn')))
$runtimeTextFiles.Add((Get-Item -LiteralPath (Join-Path $projectRoot 'project.godot')))
# Accept only canonical resource-path characters. A runtime script can contain a
# regex literal such as `res://assets/[A-Za-z0-9_./-]+\.png`; treating the regex
# character class as part of an APK entry would create a false missing-payload
# failure after an otherwise valid export.
$resourcePathPattern = [regex]'res://[A-Za-z0-9_./-]+'
foreach ($runtimeTextFile in $runtimeTextFiles) {
    $runtimeText = Get-Content -LiteralPath $runtimeTextFile.FullName -Raw
    foreach ($match in $resourcePathPattern.Matches($runtimeText)) {
        $relativeResourcePath = $match.Value.Substring(6)
        # Approved visual targets under docs/ are local validation references,
        # not runtime payload. The Android presets intentionally exclude the
        # entire documentation tree, so requiring those report-only PNGs here
        # would contradict the export contract and bloat the installed game.
        if ($relativeResourcePath.StartsWith('docs/', [System.StringComparison]::OrdinalIgnoreCase)) {
            continue
        }
        if ($relativeResourcePath.EndsWith('.tscn', [System.StringComparison]::OrdinalIgnoreCase)) {
            continue
        }
        if ($relativeResourcePath.EndsWith('.gd', [System.StringComparison]::OrdinalIgnoreCase)) {
            $scriptBase = $relativeResourcePath.Substring(0, $relativeResourcePath.Length - 3)
            [void]$requiredEntries.Add('assets/' + $scriptBase + '.gdc')
            [void]$requiredScriptPayloadEntries.Add('assets/' + $scriptBase + '.gdc')
            [void]$requiredScriptPayloadEntries.Add('assets/' + $scriptBase + '.gd.remap')
            [void]$requiredScriptBases.Add($scriptBase)
            continue
        }
        $sourceResourcePath = Join-Path $projectRoot $relativeResourcePath.Replace('/', '\')
        # Some runtime guards contain canonical resource-directory prefixes such as
        # `res://data/plants/`. They are not APK entries; concrete manifest files are
        # validated separately below.
        if (Test-Path -LiteralPath $sourceResourcePath -PathType Container) {
            continue
        }
        if (Test-Path -LiteralPath ($sourceResourcePath + '.import')) {
            [void]$requiredEntries.Add('assets/' + $relativeResourcePath + '.import')
        } elseif (Test-Path -LiteralPath $sourceResourcePath -PathType Leaf) {
            [void]$requiredEntries.Add('assets/' + $relativeResourcePath)
        } elseif ([string]::IsNullOrWhiteSpace([System.IO.Path]::GetExtension($relativeResourcePath))) {
            # A formatted runtime path such as
            # `res://assets/.../room_plant_%s_phase169.png` is intentionally
            # captured only up to the `%` by the conservative regex above.
            # The resulting extensionless prefix is not an APK entry. Concrete
            # files from the same family are still discovered through their
            # static profile paths and their `.import` metadata.
            continue
        } else {
            throw "Runtime source references a missing resource: $relativeResourcePath"
        }
    }
}
$plantManifestRelativePath = 'data/plants/catalog.json'
$plantManifestPath = Join-Path $projectRoot $plantManifestRelativePath.Replace('/', '\')
if (-not (Test-Path -LiteralPath $plantManifestPath)) {
    throw 'Plant catalog manifest is missing.'
}
$plantManifest = Get-Content -LiteralPath $plantManifestPath -Raw | ConvertFrom-Json
if ($null -eq $plantManifest -or [int]$plantManifest.version -ne 1 -or $null -eq $plantManifest.profiles -or $plantManifest.profiles.Count -lt 1) {
    throw 'Plant catalog manifest is malformed or unsupported.'
}
[void]$requiredEntries.Add('assets/' + $plantManifestRelativePath)
$manifestIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$manifestPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$manifestOrders = [System.Collections.Generic.HashSet[int]]::new()
$previousManifestOrder = -1
foreach ($profileEntry in $plantManifest.profiles) {
    $profileId = [string]$profileEntry.id
    $profileResourcePath = [string]$profileEntry.path
    $profileOrder = [int]$profileEntry.catalog_order
    if ($profileId -notmatch '^[a-z0-9_]{1,64}$' -or $profileResourcePath -notmatch '^res://data/plants/[a-z0-9_]+\.json$') {
        throw "Plant catalog manifest contains a non-canonical entry: $profileId"
    }
    if ($profileOrder -le 0 -or -not $manifestIds.Add($profileId) -or -not $manifestPaths.Add($profileResourcePath) -or -not $manifestOrders.Add($profileOrder) -or $profileOrder -le $previousManifestOrder) {
        throw "Plant catalog manifest contains duplicate or unsorted data: $profileId"
    }
    $sourceProfilePath = Join-Path $projectRoot $profileResourcePath.Substring(6).Replace('/', '\')
    if (-not (Test-Path -LiteralPath $sourceProfilePath)) {
        throw "Plant catalog manifest references a missing profile: $profileResourcePath"
    }
    [void]$requiredEntries.Add('assets/' + $profileResourcePath.Substring(6))
    $plantProfile = Get-Content -LiteralPath $sourceProfilePath -Raw | ConvertFrom-Json
    if ($null -eq $plantProfile -or [string]$plantProfile.id -ne $profileId) {
        throw "Plant profile id does not match its manifest entry: $profileResourcePath"
    }
    $profileTexturePaths = [System.Collections.Generic.List[string]]::new()
    $profileTexturePaths.Add([string]$plantProfile.seed_preview_texture)
    $profileTexturePaths.Add([string]$plantProfile.herbarium_texture)
    if ($null -eq $plantProfile.stage_textures) {
        throw "Plant profile is missing stage_textures: $profileResourcePath"
    }
    foreach ($stageTextureProperty in $plantProfile.stage_textures.PSObject.Properties) {
        $profileTexturePaths.Add([string]$stageTextureProperty.Value)
    }
    foreach ($profileTexturePath in $profileTexturePaths) {
        if ($profileTexturePath -notmatch '^res://assets/[a-zA-Z0-9_./-]+\.png$') {
            throw "Plant profile contains a non-canonical texture path: $profileResourcePath -> $profileTexturePath"
        }
        $relativeTexturePath = $profileTexturePath.Substring(6)
        $sourceTexturePath = Join-Path $projectRoot $relativeTexturePath.Replace('/', '\')
        if (-not (Test-Path -LiteralPath $sourceTexturePath)) {
            throw "Plant profile references a missing texture: $profileResourcePath -> $profileTexturePath"
        }
        if (Test-Path -LiteralPath ($sourceTexturePath + '.import')) {
            [void]$requiredEntries.Add('assets/' + $relativeTexturePath + '.import')
        } else {
            [void]$requiredEntries.Add('assets/' + $relativeTexturePath)
        }
    }
    $previousManifestOrder = $profileOrder
}
$defaultProfileId = [string]$plantManifest.default_profile_id
if (-not $manifestIds.Contains($defaultProfileId)) {
    throw 'Plant catalog default_profile_id is not present in profiles.'
}
if (-not ($apkEntries | Where-Object { $_ -match '^assets/\.godot/exported/.+-main\.scn$' })) {
    throw 'APK is missing the compiled main scene.'
}
if (-not ($apkEntries | Where-Object { $_ -match '^assets/\.godot/exported/.+-startup\.scn$' })) {
    throw 'APK is missing the compiled animated startup scene.'
}
foreach ($requiredEntry in $requiredEntries) {
    if (-not $apkEntries.Contains($requiredEntry)) {
        throw "APK is missing required runtime payload: $requiredEntry"
    }
}
$scriptPayloadOrphans = $apkEntries | Where-Object { $_ -match '^assets/.+\.gdc$' -or $_ -match '^assets/.+\.gd\.remap$' }
if ($scriptPayloadOrphans.Count -gt 0) {
    $scriptPayloadBasePattern = [regex]'^(.+)\.(gdc|gd\.remap)$'
    foreach ($runtimeScriptEntry in $scriptPayloadOrphans) {
        if (-not $requiredScriptPayloadEntries.Contains($runtimeScriptEntry)) {
            throw "APK contains orphan script payload entry: $runtimeScriptEntry"
        }
        $runtimeScriptMatch = $scriptPayloadBasePattern.Match($runtimeScriptEntry)
        if ($runtimeScriptMatch.Success) {
            $compiledBase = $runtimeScriptMatch.Groups[1].Value
            if ($runtimeScriptEntry -like '*.gd.remap') {
                $scriptPayloadBasesRemap[$compiledBase] = $true
            } else {
                $scriptPayloadBasesGdc[$compiledBase] = $true
            }
        }
    }
}
foreach ($scriptBase in $requiredScriptBases) {
    $compiledBase = 'assets/' + $scriptBase
    $compiledGdc = $compiledBase + '.gdc'
    $compiledRemap = $compiledBase + '.gd.remap'
    if (-not $requiredScriptPayloadEntries.Contains($compiledGdc) -or -not $requiredScriptPayloadEntries.Contains($compiledRemap)) {
        throw 'Script payload requires both .gdc and .gd.remap entries: ' + $scriptBase
    }
    if (-not $scriptPayloadBasesGdc.ContainsKey($compiledBase) -or -not $scriptPayloadBasesRemap.ContainsKey($compiledBase)) {
        throw 'APK is missing paired script payload entries for: ' + $scriptBase
    }
}
$textScriptEntries = $apkEntries | Where-Object { $_ -match '^assets/.+\.gd$' }
if ($textScriptEntries.Count -gt 0) {
    $textScriptList = $textScriptEntries -join ', '
    throw "APK contains raw script text resources instead of compiled payload: $textScriptList"
}
$forbiddenEntries = @(
    '^assets/docs/',
    '^assets/tests/',
    '^assets/tools/',
    'source_v1',
    'chroma_v1',
    'reference_phase'
)
foreach ($forbiddenEntry in $forbiddenEntries) {
    if ($apkEntries -match $forbiddenEntry) {
        throw "APK contains a forbidden production artifact: $forbiddenEntry"
    }
}
Assert-AndroidQaDonorPayloadContract -Entries $apkEntries -Format APK
Write-Output 'APK_PAYLOAD_CHECK=PASSED'

$apkAnalyzerRoot = Join-Path $androidSdkRoot 'cmdline-tools\latest'
$apkAnalyzerClasspath = Join-Path $apkAnalyzerRoot 'lib\apkanalyzer-classpath.jar'
$javaPath = Join-Path $javaHome 'bin\java.exe'
if (-not (Test-Path -LiteralPath $apkAnalyzerClasspath)) {
    throw 'Android APK analyzer is missing from the portable toolchain.'
}
$apkAnalyzerSystemProperty = "-Dcom.android.sdklib.toolsdir=$(Join-Path $apkAnalyzerRoot 'bin\..')"
$manifestText = (& $javaPath $apkAnalyzerSystemProperty -classpath $apkAnalyzerClasspath com.android.tools.apk.analyzer.ApkAnalyzerCli manifest print $apkPath) -join "`n"
if ($LASTEXITCODE -ne 0) {
    throw 'Could not inspect the merged Android manifest.'
}
$requiredManifestTokens = @(
    'android.permission.POST_NOTIFICATIONS',
    'android.permission.RECEIVE_BOOT_COMPLETED',
    'com.howtogrow.notifications.CareNotificationReceiver',
    'com.howtogrow.notifications.CareBootReceiver',
    'android:enableOnBackInvokedCallback="false"'
)
foreach ($token in $requiredManifestTokens) {
    if ($manifestText -notmatch [regex]::Escape($token)) {
        throw "APK is missing required Android manifest entry: $token"
    }
}
Assert-AndroidMergedManifestContract -ManifestText $manifestText -PresetContract $presetContract
Write-Output 'APK_MANIFEST_CONTRACT=PASSED'
$dexPackages = (& $javaPath $apkAnalyzerSystemProperty -classpath $apkAnalyzerClasspath com.android.tools.apk.analyzer.ApkAnalyzerCli dex packages $apkPath) -join "`n"
if ($LASTEXITCODE -ne 0) {
	throw 'Could not inspect compiled Android DEX packages.'
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
		throw "APK is missing required notification deep-link code: $token"
	}
}
Write-Output 'ANDROID_NOTIFICATION_PAYLOAD_CHECK=PASSED'
Assert-AndroidDexPrivacyContract -DexPackagesText $dexPackages
Write-Output 'APK_PRIVACY_SDK_ALLOWLIST=PASSED'

Assert-Apk16KiBAlignment -ApkPath $apkPath -ZipAlignPath $zipAlignPath
Write-Output 'APK_16K_ALIGNMENT_CHECK=PASSED'

$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $apkPath
$sizeMiB = [math]::Round((Get-Item -LiteralPath $apkPath).Length / 1MB, 2)
Write-Output "APK_READY=$apkPath"
Write-Output "APK_SIZE_MIB=$sizeMiB"
Write-Output "SHA256=$($hash.Hash)"
