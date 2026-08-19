param(
    [string]$GodotPath = 'C:\_projekty\Godot_v4.7-stable_win64.exe',
    [string]$PythonPath = 'C:\Users\drikv\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$projectConfig = Get-Content -LiteralPath (Join-Path $projectRoot 'project.godot') -Raw
$presetConfig = Get-Content -LiteralPath (Join-Path $projectRoot 'export_presets.cfg') -Raw
$sessionSource = Get-Content -LiteralPath (Join-Path $projectRoot 'scripts\game_session.gd') -Raw
$projectVersion = [regex]::Match($projectConfig, 'config/version="([^"]+)"').Groups[1].Value
$androidVersion = [regex]::Match($presetConfig, 'version/name="([^"]+)"').Groups[1].Value
$androidVersionCode = [int][regex]::Match($presetConfig, 'version/code=(\d+)').Groups[1].Value
$saveSchema = [int][regex]::Match($sessionSource, 'const SAVE_SCHEMA := (\d+)').Groups[1].Value
if (-not $projectVersion -or $projectVersion -ne $androidVersion -or $saveSchema -lt 1) {
    throw "Release metadata mismatch: project=$projectVersion android=$androidVersion schema=$saveSchema"
}
$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$artifactDirectory = Join-Path $projectRoot ".godot\release-candidate\$timestamp"
$safeVersion = $projectVersion -replace '[^0-9A-Za-z._-]', '-'
$versionedApkPath = Join-Path $projectRoot "builds\android\bazals-pocket-garden-$safeVersion-arm64-debug.apk"
if (Test-Path -LiteralPath $versionedApkPath) {
    throw "Immutable Android artifact already exists at $versionedApkPath and remains untouched. Bump the release version before rerun."
}

New-Item -ItemType Directory -Path $artifactDirectory -Force | Out-Null
$temporaryApkPath = Join-Path $artifactDirectory "bazals-pocket-garden-$safeVersion-arm64-debug.pending.apk"

& (Join-Path $projectRoot '.agents\skills\how-to-grow-validation\scripts\run_validation.ps1') -GodotPath $GodotPath -PythonPath $PythonPath
if ($LASTEXITCODE -ne 0) { throw 'Deterministic validation failed.' }
& (Join-Path $projectRoot 'tools\run_performance_smoke.ps1') -GodotPath $GodotPath
if ($LASTEXITCODE -ne 0) { throw 'Performance smoke failed.' }
& (Join-Path $projectRoot 'tools\run_endurance_smoke.ps1') -GodotPath $GodotPath
if ($LASTEXITCODE -ne 0) { throw 'Endurance smoke failed.' }
& (Join-Path $projectRoot 'tools\run_progression_smoke.ps1') -GodotPath $GodotPath
if ($LASTEXITCODE -ne 0) { throw 'Progression smoke failed.' }
$progressionReportPath = Get-ChildItem -LiteralPath (Join-Path $projectRoot '.godot\progression') -Directory |
    Sort-Object LastWriteTimeUtc -Descending |
    ForEach-Object { Join-Path $_.FullName 'progression-smoke.json' } |
    Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
    Select-Object -First 1
if (-not $progressionReportPath) {
    throw 'Progression smoke did not produce its audit report.'
}
$progressionReport = Get-Content -LiteralPath $progressionReportPath -Raw | ConvertFrom-Json
$progressionCycles = [int]$progressionReport.cycles
$progressionTargetCycles = [int]$progressionReport.target_cycles
$progressionSaveRoundtrips = [int]$progressionReport.save_roundtrips
$progressionSpeciesCount = @($progressionReport.species.PSObject.Properties).Count
if ([string]$progressionReport.result -ne 'PASSED' -or $progressionCycles -ne $progressionTargetCycles -or $progressionSpeciesCount -lt 1) {
    throw "Progression report is incomplete: cycles=$progressionCycles/$progressionTargetCycles species=$progressionSpeciesCount"
}
& (Join-Path $projectRoot 'tools\run_responsive_layout_smoke.ps1') -GodotPath $GodotPath
if ($LASTEXITCODE -ne 0) { throw 'Responsive layout smoke failed.' }
& (Join-Path $projectRoot 'tools\export_android.ps1') -GodotPath $GodotPath -ApkPath $temporaryApkPath
if ($LASTEXITCODE -ne 0) { throw 'Android debug export failed.' }
$apkHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $temporaryApkPath).Hash
if (Test-Path -LiteralPath $versionedApkPath) {
    throw "Immutable Android artifact appeared during the release run at $versionedApkPath; the validated pending APK remains in the release evidence directory."
}
Move-Item -LiteralPath $temporaryApkPath -Destination $versionedApkPath
$installedApkHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $versionedApkPath).Hash
if ($installedApkHash -ne $apkHash) {
    throw 'Immutable Android artifact hash changed while it was installed.'
}
$apkPath = $versionedApkPath
$report = [ordered]@{
    generated_utc = [DateTime]::UtcNow.ToString('o')
    version = $projectVersion
    version_code = $androidVersionCode
    save_schema = $saveSchema
    validation = 'PASSED'
    performance = 'PASSED_DESKTOP_ACTIVE_FULL_RACK'
    endurance = 'PASSED_48_UI_SIMULATION_SAVE_CYCLES'
    progression = "PASSED_${progressionCycles}_CYCLES_${progressionSpeciesCount}_SPECIES_${progressionSaveRoundtrips}_SAVE_ROUNDTRIPS"
    progression_report = $progressionReportPath
    responsive_layout = 'PASSED_7_DISPLAY_AND_SAFE_AREA_CASES'
    android_debug_apk = $versionedApkPath
    apk_sha256 = $apkHash
    android_notification_payload = 'PASSED_STATIC_AND_APK'
    physical_android_gate = 'PENDING'
    publishing_gate = 'PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW'
}
$report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $artifactDirectory 'release-candidate.json') -Encoding utf8
$markdown = @"
# Bazal’s Pocket Garden $projectVersion

- Version code: $androidVersionCode
- Save schema: $saveSchema
- Deterministic validation: PASSED
- Active full-rack desktop performance: PASSED
- Endurance UI/simulation/save cycles: PASSED
- Progression/economy/save campaign: PASSED ($progressionCycles/$progressionTargetCycles cycles, $progressionSpeciesCount species, $progressionSaveRoundtrips save/load roundtrips)
- Immutable Android artifact: $versionedApkPath
- Responsive display/safe-area matrix: PASSED
- Android debug APK SHA-256: $apkHash
- Android notification payload: PASSED_STATIC_AND_APK
- PHYSICAL_ANDROID_GATE: PENDING
- PUBLISHING_GATE: PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW
"@
$markdown | Set-Content -LiteralPath (Join-Path $artifactDirectory 'release-candidate.md') -Encoding utf8
Write-Output "RELEASE_CANDIDATE=PASSED_LOCAL"
Write-Output "PHYSICAL_ANDROID_GATE=PENDING"
Write-Output "RELEASE_CANDIDATE_ARTIFACTS=$artifactDirectory"
