param(
    [ValidateSet('Quick', 'Full', 'Release', 'ReleaseDevice')]
    [string]$Mode = 'Full',
    [string]$GodotPath = 'C:\_projekty\Godot_v4.7-stable_win64.exe',
    [string]$PythonPath = 'C:\Users\drikv\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe',
    [string]$AdbPath = '',
    [string]$Serial = '',
    [switch]$PublishingRequested,
    [ValidateRange(20, 1800)]
    [int]$DeviceSampleSeconds = 300
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$artifactDirectory = Join-Path $projectRoot ".godot\automation\$timestamp"
[System.IO.Directory]::CreateDirectory($artifactDirectory) | Out-Null

$projectConfig = Get-Content -LiteralPath (Join-Path $projectRoot 'project.godot') -Raw
$presetConfig = Get-Content -LiteralPath (Join-Path $projectRoot 'export_presets.cfg') -Raw
$sessionSource = Get-Content -LiteralPath (Join-Path $projectRoot 'scripts\game_session.gd') -Raw
$projectVersion = [regex]::Match($projectConfig, 'config/version="([^"]+)"').Groups[1].Value
$androidVersion = [regex]::Match($presetConfig, 'version/name="([^"]+)"').Groups[1].Value
$androidVersionCode = [regex]::Match($presetConfig, 'version/code=(\d+)').Groups[1].Value
$saveSchemaMatch = [regex]::Match($sessionSource, '(?m)^\s*const\s+SAVE_SCHEMA(?:\s*:\s*\w+)?\s*(?::=|=)\s*(\d+)\b')
if (-not $projectVersion -or $projectVersion -ne $androidVersion -or -not $androidVersionCode -or -not $saveSchemaMatch.Success) {
    throw "Automation metadata mismatch: project=$projectVersion android=$androidVersion code=$androidVersionCode schema=$($saveSchemaMatch.Groups[1].Value)"
}
$saveSchema = [int]$saveSchemaMatch.Groups[1].Value
$safeVersion = $projectVersion -replace '[^0-9A-Za-z._-]', '-'
$versionedApkPath = Join-Path $projectRoot "builds\android\bazals-pocket-garden-$safeVersion-arm64-debug.apk"

$steps = [System.Collections.Generic.List[object]]::new()
$technicalStatus = 'RUNNING'
$deviceStatus = if ($Mode -eq 'ReleaseDevice') { 'RUNNING' } else { 'NOT_REQUESTED' }
$failureMessage = ''
$manualGate = 'PENDING_SINGLE_HUMAN_BATCH'
$publishingGate = if ($PublishingRequested) { 'PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW' } else { 'OUT_OF_SCOPE_BY_USER' }
$reportJsonPath = Join-Path $artifactDirectory 'automation-report.json'
$reportMarkdownPath = Join-Path $artifactDirectory 'automation-report.md'
$worktreePath = Join-Path $artifactDirectory 'worktree-status.txt'

$worktreeStatus = [System.Collections.Generic.List[string]]::new()
$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if ($gitCommand) {
    $gitOutput = @(& $gitCommand.Source -C $projectRoot status --short 2>&1)
    $gitExitCode = $LASTEXITCODE
    if ($gitExitCode -eq 0) {
        foreach ($line in $gitOutput) {
            if (-not [string]::IsNullOrWhiteSpace([string]$line)) {
                $worktreeStatus.Add([string]$line)
            }
        }
    } else {
        $worktreeStatus.Add("GIT_STATUS_UNAVAILABLE_EXIT_$gitExitCode")
    }
} else {
    $worktreeStatus.Add('GIT_STATUS_UNAVAILABLE')
}
[System.IO.File]::WriteAllLines($worktreePath, $worktreeStatus, [System.Text.UTF8Encoding]::new($false))
$worktreeDirty = $worktreeStatus.Count -gt 0 -and -not $worktreeStatus[0].StartsWith('GIT_STATUS_UNAVAILABLE')

function Invoke-CheckedScript {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [string[]]$Arguments,
        [string[]]$RequiredMarkers
    )
    if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) {
        throw "Automation step $Name is missing its runner: $ScriptPath"
    }

    $safeName = $Name.ToLowerInvariant() -replace '[^0-9a-z]+', '-'
    $logPath = Join-Path $artifactDirectory "$safeName.log"
    $commandArguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $ScriptPath)
    $commandArguments += $Arguments
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        # Child runners may write their own failure details to stderr. Capture
        # both streams and evaluate the native exit code plus explicit markers.
        $ErrorActionPreference = 'Continue'
        $rawOutput = @(& powershell.exe @commandArguments 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    $outputText = ($rawOutput | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
    if ($outputText) {
        $outputText += [Environment]::NewLine
    }
    [System.IO.File]::WriteAllText($logPath, $outputText, [System.Text.UTF8Encoding]::new($false))

    $matchedMarkers = [System.Collections.Generic.List[string]]::new()
    $missingMarkers = [System.Collections.Generic.List[string]]::new()
    foreach ($pattern in $RequiredMarkers) {
        $match = [regex]::Match($outputText, $pattern)
        if ($match.Success) {
            $matchedMarkers.Add($match.Value)
        } else {
            $missingMarkers.Add($pattern)
        }
    }
    $forbiddenErrors = [regex]::IsMatch($outputText, 'SCRIPT ERROR|Parse Error|MVP TESTY SELHALY')
    $status = if ($exitCode -eq 0 -and $missingMarkers.Count -eq 0 -and -not $forbiddenErrors) { 'PASSED' } else { 'FAILED' }
    $steps.Add([pscustomobject][ordered]@{
        name = $Name
        status = $status
        exit_code = $exitCode
        markers = @($matchedMarkers)
        missing_markers = @($missingMarkers)
        forbidden_error_marker = $forbiddenErrors
        log = $logPath
    })
    $stepKey = $Name.ToUpperInvariant() -replace '[^0-9A-Z]+', '_'
    Write-Output "AUTOMATION_STEP_${stepKey}=$status"
    if ($status -ne 'PASSED') {
        Write-Output "AUTOMATION_STEP_FAILURE_LOG=$logPath"
        throw "Automation step $Name failed: exit=$exitCode missing_markers=$($missingMarkers -join ',') forbidden_error_marker=$forbiddenErrors"
    }
}

function Write-AutomationReport {
    $stepArray = @($steps | ForEach-Object { $_ })
    $report = [ordered]@{
        generated_utc = [DateTime]::UtcNow.ToString('o')
        mode = $Mode
        version = $projectVersion
        version_code = [int]$androidVersionCode
        save_schema = $saveSchema
        technical_gate = $technicalStatus
        device_gate = $deviceStatus
        manual_gate = $manualGate
        publishing_gate = $publishingGate
        worktree_dirty = $worktreeDirty
        worktree_status = $worktreePath
        immutable_android_apk = $versionedApkPath
        immutable_android_apk_exists = (Test-Path -LiteralPath $versionedApkPath -PathType Leaf)
        failure = $failureMessage
        steps = $stepArray
    }
    [System.IO.File]::WriteAllText(
        $reportJsonPath,
        ($report | ConvertTo-Json -Depth 8),
        [System.Text.UTF8Encoding]::new($false)
    )

    $markdown = [System.Collections.Generic.List[string]]::new()
    $markdown.Add("# Project automation $timestamp")
    $markdown.Add('')
    $markdown.Add("- Mode: $Mode")
    $markdown.Add("- Version: $projectVersion ($androidVersionCode)")
    $markdown.Add("- Save schema: $saveSchema")
    $markdown.Add("- Technical gate: $technicalStatus")
    $markdown.Add("- Device gate: $deviceStatus")
    $markdown.Add("- Working tree dirty: $worktreeDirty")
    $markdown.Add("- Manual gate: $manualGate")
    $markdown.Add("- Publishing gate: $publishingGate")
    if ($failureMessage) {
        $markdown.Add("- Failure: $failureMessage")
    }
    $markdown.Add('')
    $markdown.Add('## Automated steps')
    $markdown.Add('')
    foreach ($step in $stepArray) {
        $markdown.Add("- $($step.name): $($step.status), exit $($step.exit_code), log $($step.log)")
    }
    $markdown.Add('')
    $markdown.Add('## One remaining human batch')
    $markdown.Add('')
    $markdown.Add('- Physical readability, touch feel, animation comfort and hardware heat/battery judgment.')
    $markdown.Add('- Android document picker backup/import and deliberately destructive new-game/restore confirmation flow.')
    $markdown.Add('- Real notification delivery, tap destination and persistence across a phone reboot.')
    $markdown.Add('')
    $markdown.Add('These observations are never auto-approved. They are reported once after the automated workflow, not requested as step-by-step prompts.')
    [System.IO.File]::WriteAllLines($reportMarkdownPath, $markdown, [System.Text.UTF8Encoding]::new($false))
}

try {
    switch ($Mode) {
        'Quick' {
            Invoke-CheckedScript `
                -Name 'VisualContract' `
                -ScriptPath (Join-Path $projectRoot 'tools\run_visual_contract_audit.ps1') `
                -Arguments @('-GodotPath', $GodotPath) `
                -RequiredMarkers @('VISUAL_CONTRACT_AUDIT=PASSED')
            Invoke-CheckedScript `
                -Name 'Regression' `
                -ScriptPath (Join-Path $projectRoot 'tools\run_tests.ps1') `
                -Arguments @('-GodotPath', $GodotPath) `
                -RequiredMarkers @('MVP_TESTS_PASSED=\d+')
        }
        'Full' {
            Invoke-CheckedScript `
                -Name 'VisualContract' `
                -ScriptPath (Join-Path $projectRoot 'tools\run_visual_contract_audit.ps1') `
                -Arguments @('-GodotPath', $GodotPath) `
                -RequiredMarkers @('VISUAL_CONTRACT_AUDIT=PASSED')
            Invoke-CheckedScript `
                -Name 'Validation' `
                -ScriptPath (Join-Path $projectRoot '.agents\skills\how-to-grow-validation\scripts\run_validation.ps1') `
                -Arguments @('-ProjectRoot', $projectRoot, '-GodotPath', $GodotPath, '-PythonPath', $PythonPath) `
                -RequiredMarkers @('MVP_TESTS_PASSED=\d+', 'HOW_TO_GROW_VALIDATION=PASSED')
            Invoke-CheckedScript -Name 'Performance' -ScriptPath (Join-Path $projectRoot 'tools\run_performance_smoke.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('PERFORMANCE_SMOKE=PASSED')
            Invoke-CheckedScript -Name 'Endurance' -ScriptPath (Join-Path $projectRoot 'tools\run_endurance_smoke.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('ENDURANCE_SMOKE=PASSED')
            Invoke-CheckedScript -Name 'Progression' -ScriptPath (Join-Path $projectRoot 'tools\run_progression_smoke.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('PROGRESSION_SMOKE=PASSED')
            Invoke-CheckedScript -Name 'Responsive' -ScriptPath (Join-Path $projectRoot 'tools\run_responsive_layout_smoke.ps1') -Arguments @('-GodotPath', $GodotPath) -RequiredMarkers @('RESPONSIVE_LAYOUT_SMOKE=PASSED')
        }
        { $_ -in @('Release', 'ReleaseDevice') } {
            if (Test-Path -LiteralPath $versionedApkPath -PathType Leaf) {
                throw "Immutable Android artifact already exists and remains untouched: $versionedApkPath. Bump the release version before using $Mode."
            }
            $releaseArguments = @('-GodotPath', $GodotPath, '-PythonPath', $PythonPath)
            if ($PublishingRequested) {
                $releaseArguments += '-PublishingRequested'
            }
            Invoke-CheckedScript `
                -Name 'ReleaseCandidate' `
                -ScriptPath (Join-Path $projectRoot 'tools\run_release_candidate.ps1') `
                -Arguments $releaseArguments `
                -RequiredMarkers @('RELEASE_CANDIDATE=PASSED_LOCAL', 'RELEASE_CANDIDATE_ALIAS=PASSED')
            if (-not (Test-Path -LiteralPath $versionedApkPath -PathType Leaf)) {
                throw "Release runner passed without creating the expected immutable APK: $versionedApkPath"
            }
            if ($Mode -eq 'ReleaseDevice') {
                $deviceArguments = @('-Install', '-ApkPath', $versionedApkPath, '-SampleSeconds', [string]$DeviceSampleSeconds)
                if ($AdbPath) {
                    $deviceArguments += @('-AdbPath', $AdbPath)
                }
                if ($Serial) {
                    $deviceArguments += @('-Serial', $Serial)
                }
                Invoke-CheckedScript `
                    -Name 'AndroidDevice' `
                    -ScriptPath (Join-Path $projectRoot 'tools\run_android_device_audit.ps1') `
                    -Arguments $deviceArguments `
                    -RequiredMarkers @('ANDROID_TECHNICAL_GATE=PASSED', 'ANDROID_DEVICE_AUDIT=CAPTURED')
                $deviceStatus = 'PASSED_TECHNICAL'
            }
        }
    }
    $technicalStatus = 'PASSED'
} catch {
    $technicalStatus = 'FAILED'
    if ($deviceStatus -eq 'RUNNING') {
        $deviceStatus = 'FAILED_OR_NOT_COMPLETED'
    }
    $failureMessage = $_.Exception.Message
} finally {
    Write-AutomationReport
}

Write-Output "AUTOMATION_MODE=$Mode"
Write-Output "AUTOMATION_ARTIFACTS=$artifactDirectory"
Write-Output "AUTOMATION_REPORT=$reportMarkdownPath"
Write-Output "AUTOMATION_TECHNICAL_GATE=$technicalStatus"
Write-Output "AUTOMATION_DEVICE_GATE=$deviceStatus"
Write-Output "AUTOMATION_MANUAL_GATE=$manualGate"
Write-Output "AUTOMATION_PUBLISHING_GATE=$publishingGate"
if ($technicalStatus -ne 'PASSED') {
    Write-Output 'HOW_TO_GROW_AUTOMATION=FAILED'
    throw $failureMessage
}
Write-Output 'HOW_TO_GROW_AUTOMATION=PASSED'
