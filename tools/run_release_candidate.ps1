param(
    [string]$GodotPath = 'C:\_projekty\Godot_v4.7-stable_win64.exe',
    [string]$PythonPath = 'C:\Users\drikv\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe',
    [switch]$PublishingRequested
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
$defaultApkPath = Join-Path $projectRoot 'builds\android\bazals-pocket-garden-debug.apk'
$publishingGate = if ($PublishingRequested) { 'PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW' } else { 'OUT_OF_SCOPE_BY_USER' }
$defaultApkPendingPath = "$defaultApkPath.$timestamp.pending"
if (Test-Path -LiteralPath $versionedApkPath) {
    throw "Immutable Android artifact already exists at $versionedApkPath and remains untouched. Bump the release version before rerun."
}

New-Item -ItemType Directory -Path $artifactDirectory -Force | Out-Null
$temporaryApkPath = Join-Path $artifactDirectory "bazals-pocket-garden-$safeVersion-arm64-debug.pending.apk"

function Invoke-ReleaseGate {
	param(
		[string]$Name,
		[string]$ScriptPath,
		[string[]]$Arguments,
		[string[]]$RequiredMarkers
	)
	$previousErrorActionPreference = $ErrorActionPreference
	try {
		# Expected negative-path regression checks and Godot cleanup diagnostics
		# may use stderr. Capture both streams and decide only from the child exit,
		# required markers and the explicit forbidden marker set below.
		$ErrorActionPreference = 'Continue'
		$rawOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments 2>&1)
		$exitCode = $LASTEXITCODE
	} finally {
		$ErrorActionPreference = $previousErrorActionPreference
	}
	$rawOutput | ForEach-Object { Write-Host $_ }
	$outputText = ($rawOutput | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
	$missingMarkers = @($RequiredMarkers | Where-Object { $outputText -notmatch $_ })
	$forbiddenErrors = $outputText -match 'SCRIPT ERROR|Parse Error|MVP TESTY SELHALY|HOW_TO_GROW_[A-Z_]+=FAILED'
	if ($exitCode -ne 0 -or $missingMarkers.Count -ne 0 -or $forbiddenErrors) {
		throw "$Name failed: exit=$exitCode missing_markers=$($missingMarkers -join ',') forbidden_error_marker=$forbiddenErrors"
	}
	return [pscustomobject]@{
		Lines = $rawOutput
		Text = $outputText
		ExitCode = $exitCode
	}
}

$visualContractGate = Invoke-ReleaseGate -Name 'Phase 127 visual contract audit' -ScriptPath (Join-Path $projectRoot 'tools\run_visual_contract_audit.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('VISUAL_CONTRACT_AUDIT=PASSED')
$validationGate = Invoke-ReleaseGate -Name 'Deterministic validation' -ScriptPath (Join-Path $projectRoot '.agents\skills\how-to-grow-validation\scripts\run_validation.ps1') -Arguments @('-GodotPath', $GodotPath, '-PythonPath', $PythonPath) -RequiredMarkers @('MVP_TESTS_PASSED=\d+', 'HOW_TO_GROW_VALIDATION=PASSED')
$performanceGate = Invoke-ReleaseGate -Name 'Performance smoke' -ScriptPath (Join-Path $projectRoot 'tools\run_performance_smoke.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('PERFORMANCE_SMOKE=PASSED')
$enduranceGate = Invoke-ReleaseGate -Name 'Endurance smoke' -ScriptPath (Join-Path $projectRoot 'tools\run_endurance_smoke.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('ENDURANCE_SMOKE=PASSED')
$progressionGate = Invoke-ReleaseGate -Name 'Progression smoke' -ScriptPath (Join-Path $projectRoot 'tools\run_progression_smoke.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('PROGRESSION_SMOKE=PASSED')
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
$responsiveGate = Invoke-ReleaseGate -Name 'Responsive layout smoke' -ScriptPath (Join-Path $projectRoot 'tools\run_responsive_layout_smoke.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('RESPONSIVE_LAYOUT_SMOKE=PASSED')
$responsiveOutput = @($responsiveGate.Lines)
$responsiveArtifactsLine = $responsiveOutput |
    Where-Object { [string]$_ -match '^RESPONSIVE_ARTIFACTS=(.+)$' } |
    Select-Object -Last 1
if (-not $responsiveArtifactsLine) {
    throw 'Responsive layout smoke did not identify its artifact directory.'
}
$responsiveArtifactDirectory = [System.IO.Path]::GetFullPath(
    [regex]::Match([string]$responsiveArtifactsLine, '^RESPONSIVE_ARTIFACTS=(.+)$').Groups[1].Value.Trim()
)
$responsiveRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot '.godot\responsive'))
$responsiveRootPrefix = $responsiveRoot.TrimEnd([char[]]@('\', '/')) + [System.IO.Path]::DirectorySeparatorChar
if (-not $responsiveArtifactDirectory.StartsWith($responsiveRootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Responsive artifact directory escaped the project audit root: $responsiveArtifactDirectory"
}
$responsiveReportPath = Join-Path $responsiveArtifactDirectory 'responsive-layout.json'
if (-not (Test-Path -LiteralPath $responsiveReportPath -PathType Leaf)) {
    throw 'Responsive layout smoke did not produce its audit report.'
}
$responsiveReport = Get-Content -LiteralPath $responsiveReportPath -Raw | ConvertFrom-Json
$responsiveCaseCount = [int]$responsiveReport.matrix_cases
$responsiveCases = @($responsiveReport.cases)
$responsiveFailures = @($responsiveCases | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.failure) })
if (
    [string]$responsiveReport.result -ne 'PASSED' -or
    $responsiveCaseCount -lt 1 -or
    $responsiveCases.Count -ne $responsiveCaseCount -or
    $responsiveFailures.Count -ne 0
) {
    throw "Responsive report is incomplete: result=$($responsiveReport.result) cases=$($responsiveCases.Count)/$responsiveCaseCount failures=$($responsiveFailures.Count)"
}
$exportGate = Invoke-ReleaseGate -Name 'Android debug export' -ScriptPath (Join-Path $projectRoot 'tools\export_android.ps1') -Arguments @('-GodotPath', $GodotPath, '-ApkPath', $temporaryApkPath) -RequiredMarkers @('GODOT_GRADLE_EXPORT=PASSED', 'APK_SIGNATURE_CHECK=PASSED', 'APK_PAYLOAD_CHECK=PASSED', 'APK_READY=')
$apkHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $temporaryApkPath).Hash
if (Test-Path -LiteralPath $versionedApkPath) {
    throw "Immutable Android artifact appeared during the release run at $versionedApkPath; the validated pending APK remains in the release evidence directory."
}
if (Test-Path -LiteralPath $defaultApkPendingPath) {
    throw "Mutable Android alias staging path already exists at $defaultApkPendingPath."
}
Copy-Item -LiteralPath $temporaryApkPath -Destination $defaultApkPendingPath
$defaultApkPendingHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $defaultApkPendingPath).Hash
if ($defaultApkPendingHash -ne $apkHash) {
    throw 'Mutable Android alias staging copy does not match the immutable artifact.'
}
Move-Item -LiteralPath $temporaryApkPath -Destination $versionedApkPath
$installedApkHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $versionedApkPath).Hash
if ($installedApkHash -ne $apkHash) {
    throw 'Immutable Android artifact hash changed while it was installed.'
}
Move-Item -LiteralPath $defaultApkPendingPath -Destination $defaultApkPath -Force
$defaultApkHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $defaultApkPath).Hash
if ($defaultApkHash -ne $apkHash) {
    throw 'Mutable Android alias does not match the immutable artifact after replacement.'
}
$apkPath = $versionedApkPath
$report = [ordered]@{
    generated_utc = [DateTime]::UtcNow.ToString('o')
    version = $projectVersion
    version_code = $androidVersionCode
    save_schema = $saveSchema
    validation = 'PASSED'
    visual_contract = 'PASSED_PHASE127_ALL_PNG_PROFILED'
    performance = 'PASSED_DESKTOP_ACTIVE_FULL_RACK'
    endurance = 'PASSED_48_UI_SIMULATION_SAVE_CYCLES'
    progression = "PASSED_${progressionCycles}_CYCLES_${progressionSpeciesCount}_SPECIES_${progressionSaveRoundtrips}_SAVE_ROUNDTRIPS"
    progression_report = $progressionReportPath
    responsive_layout = "PASSED_${responsiveCaseCount}_DISPLAY_AND_SAFE_AREA_CASES"
    responsive_report = $responsiveReportPath
    android_debug_apk = $versionedApkPath
    apk_sha256 = $apkHash
    android_debug_alias = $defaultApkPath
    android_debug_alias_sha256 = $defaultApkHash
    android_notification_payload = 'PASSED_STATIC_AND_APK'
    physical_android_gate = 'PENDING'
    publishing_gate = $publishingGate
}
$report | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $artifactDirectory 'release-candidate.json') -Encoding utf8
$markdown = @"
# Bazal’s Pocket Garden $projectVersion

- Version code: $androidVersionCode
- Save schema: $saveSchema
- Deterministic validation: PASSED
- Phase 127 visual contract: PASSED (all PNG assets have an explicit or family profile)
- Active full-rack desktop performance: PASSED
- Endurance UI/simulation/save cycles: PASSED
- Progression/economy/save campaign: PASSED ($progressionCycles/$progressionTargetCycles cycles, $progressionSpeciesCount species, $progressionSaveRoundtrips save/load roundtrips)
- Immutable Android artifact: $versionedApkPath
- Mutable Android alias: $defaultApkPath
- Responsive display/safe-area matrix: PASSED ($responsiveCaseCount/$responsiveCaseCount cases)
- Android debug APK SHA-256: $apkHash
- Android debug alias SHA-256: $defaultApkHash
- Android notification payload: PASSED_STATIC_AND_APK
- PHYSICAL_ANDROID_GATE: PENDING
- PUBLISHING_GATE: $publishingGate
"@
$markdown | Set-Content -LiteralPath (Join-Path $artifactDirectory 'release-candidate.md') -Encoding utf8
Write-Output "RELEASE_CANDIDATE=PASSED_LOCAL"
Write-Output "RELEASE_CANDIDATE_ALIAS=PASSED"
Write-Output "PHYSICAL_ANDROID_GATE=PENDING"
Write-Output "PUBLISHING_GATE=$publishingGate"
Write-Output "RELEASE_CANDIDATE_ARTIFACTS=$artifactDirectory"
