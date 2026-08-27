param(
    [string]$AdbPath = '',
    [string]$Serial = '',
    [string]$ApkPath = '',
	[int]$SampleSeconds = 120,
	[switch]$Install,
	[switch]$ClearAppData,
	[switch]$SkipLaunch,
	[switch]$KeepAdbServer
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$packageName = 'com.howtogrow.game'
$projectConfig = Get-Content -LiteralPath (Join-Path $projectRoot 'project.godot') -Raw
$exportConfig = Get-Content -LiteralPath (Join-Path $projectRoot 'export_presets.cfg') -Raw
$gameSession = Get-Content -LiteralPath (Join-Path $projectRoot 'scripts\game_session.gd') -Raw
$expectedVersionName = [regex]::Match($exportConfig, 'version/name="([^"]+)"').Groups[1].Value
$expectedVersionCode = [regex]::Match($exportConfig, 'version/code=(\d+)').Groups[1].Value
$expectedSaveSchemaMatch = [regex]::Match($gameSession, '(?m)^\s*const\s+SAVE_SCHEMA(?:\s*:\s*\w+)?\s*(?::=|=)\s*(\d+)\b')
if (-not $expectedSaveSchemaMatch.Success) {
    throw 'SAVE_SCHEMA could not be parsed from scripts/game_session.gd.'
}
$expectedSaveSchema = [int]$expectedSaveSchemaMatch.Groups[1].Value

if (-not $AdbPath) {
    $AdbPath = Join-Path $projectRoot '.tooling\android-sdk\platform-tools\adb.exe'
}
if (-not (Test-Path -LiteralPath $AdbPath -PathType Leaf)) {
    throw "ADB was not found: $AdbPath"
}
if ($Install -and [string]::IsNullOrWhiteSpace($ApkPath)) {
    throw 'Install requires an explicit -ApkPath. Pass the immutable RC APK (or the release runner pending APK) so a stale generic debug alias can never be installed.'
}
if ($ClearAppData -and -not $Install) {
    throw 'ClearAppData requires -Install and remains an explicit destructive opt-in.'
}
if ($ApkPath -and -not (Test-Path -LiteralPath $ApkPath -PathType Leaf)) {
    throw "APK was not found: $ApkPath"
}
$expectedApkSha256 = 'NOT_PROVIDED'
if ($ApkPath) {
    $expectedApkSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $ApkPath).Hash.ToUpperInvariant()
}
if ($SampleSeconds -lt 20 -or $SampleSeconds -gt 1800) {
    throw 'SampleSeconds must be between 20 and 1800.'
}

$deviceRows = @(& $AdbPath devices -l | Select-Object -Skip 1 | Where-Object { $_ -match '\sdevice(?:\s|$)' })
if (-not $Serial) {
    if ($deviceRows.Count -eq 0) {
        throw 'No authorized Android device is connected. Enable USB debugging and accept the computer authorization prompt.'
    }
    if ($deviceRows.Count -gt 1) {
        throw 'More than one Android device is connected. Pass -Serial explicitly.'
    }
    $Serial = ($deviceRows[0] -split '\s+')[0]
} elseif (-not ($deviceRows | Where-Object { $_ -match ('^' + [regex]::Escape($Serial) + '\s') })) {
    throw "The requested authorized device is not connected: $Serial"
}

$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$outputRoot = Join-Path $projectRoot ".godot\android-device-audit\$timestamp"
[System.IO.Directory]::CreateDirectory($outputRoot) | Out-Null

function Invoke-Adb {
    param([string[]]$Arguments, [string]$OutputFile = '')
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        # Valid adb subcommands such as `shell monkey` write progress to stderr.
        # Capture both streams and decide from the native exit code instead.
        $ErrorActionPreference = 'Continue'
        $rawOutput = @(& $AdbPath -s $Serial @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    $output = ($rawOutput | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
    if ($output) {
        $output += [Environment]::NewLine
    }
    if ($OutputFile) {
        [System.IO.File]::WriteAllText((Join-Path $outputRoot $OutputFile), $output, [System.Text.UTF8Encoding]::new($false))
    }
    if ($exitCode -ne 0) {
        throw "ADB command failed: $($Arguments -join ' ')`n$output"
    }
    return $output
}

function Invoke-AdbPrivate {
    param([string[]]$Arguments)
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        # Private probes may contain the local save in memory. Never write their
        # raw stdout to an audit artifact or echo it as part of an exception.
        $ErrorActionPreference = 'Continue'
        $rawOutput = @(& $AdbPath -s $Serial @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    return [pscustomobject]@{
        Success = ($exitCode -eq 0)
        Output = (($rawOutput | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine)
        ExitCode = $exitCode
    }
}

function ConvertTo-LowerBoolean {
    param([bool]$Value)
    if ($Value) { return 'true' }
    return 'false'
}

function Get-JsonPropertyValue {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) {
        return $null
    }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }
    return $property.Value
}

function Get-SafeJsonInteger {
    param([object]$Object, [string]$Name)
    $value = Get-JsonPropertyValue -Object $Object -Name $Name
    if ($null -eq $value -or $value -is [bool] -or $value -isnot [System.ValueType]) {
        return $null
    }
    try {
        $numeric = [double]$value
    } catch {
        return $null
    }
    if ([double]::IsNaN($numeric) -or [double]::IsInfinity($numeric) -or $numeric -ne [Math]::Truncate($numeric) -or $numeric -lt 0 -or $numeric -gt [long]::MaxValue) {
        return $null
    }
    return [long]$numeric
}

function Get-SemanticSaveSnapshot {
    param([string]$Label)
    $snapshot = [ordered]@{
        Label = $Label
        Status = 'UNAVAILABLE'
        Schema = $null
        Coins = $null
        Xp = $null
        PlantSlotCount = $null
        OccupiedCount = $null
        StoryChapterStatus = 'UNAVAILABLE'
        StorySealCount = $null
    }

    $pathProbe = Invoke-AdbPrivate -Arguments @('shell', 'pm', 'path', $packageName)
    if (-not $pathProbe.Success -or $pathProbe.Output -notmatch 'package:') {
        $snapshot.Status = 'NOT_INSTALLED'
        return [pscustomobject]$snapshot
    }
    $runAsProbe = Invoke-AdbPrivate -Arguments @('shell', 'run-as', $packageName, 'id')
    if (-not $runAsProbe.Success) {
        $runAsProbe.Output = ''
        $snapshot.Status = 'NOT_DEBUGGABLE'
        return [pscustomobject]$snapshot
    }
    $runAsProbe.Output = ''

    $saveProbe = Invoke-AdbPrivate -Arguments @('shell', 'run-as', $packageName, 'cat', 'files/how_to_grow_save.json')
    if (-not $saveProbe.Success) {
        $snapshot.Status = 'NOT_FOUND'
        return [pscustomobject]$snapshot
    }
    $rawSave = $saveProbe.Output.Trim()
    if (-not $rawSave) {
        $snapshot.Status = 'NOT_FOUND'
        return [pscustomobject]$snapshot
    }
    try {
        $save = ConvertFrom-Json -InputObject $rawSave -ErrorAction Stop
    } catch {
        $snapshot.Status = 'INVALID_JSON'
        return [pscustomobject]$snapshot
    } finally {
        # The raw save is deliberately short-lived and is never persisted.
        $rawSave = $null
        $saveProbe.Output = ''
    }

    $schema = Get-SafeJsonInteger -Object $save -Name 'schema'
    $coins = Get-SafeJsonInteger -Object $save -Name 'coins'
    $xp = Get-SafeJsonInteger -Object $save -Name 'xp'
    $plantsValue = Get-JsonPropertyValue -Object $save -Name 'plants'
    if ($null -eq $schema -or $null -eq $coins -or $null -eq $xp -or $plantsValue -isnot [System.Array]) {
        $snapshot.Status = 'UNSAFE_STRUCTURE'
        return [pscustomobject]$snapshot
    }
    $plants = @($plantsValue)
    $occupiedCount = 0
    foreach ($plant in $plants) {
        $stage = Get-SafeJsonInteger -Object $plant -Name 'stage'
        if ($null -eq $stage) {
            $snapshot.Status = 'UNSAFE_STRUCTURE'
            return [pscustomobject]$snapshot
        }
        if ($stage -gt 0) {
            $occupiedCount += 1
        }
    }

    $storyStatus = 'NOT_PRESENT'
    $storySealCount = 0
    $activeStoryId = Get-JsonPropertyValue -Object $save -Name 'active_story_chapter_id'
    $chapters = Get-JsonPropertyValue -Object $save -Name 'story_chapters'
    if ($null -ne $activeStoryId -and $activeStoryId -isnot [string]) {
        $storyStatus = 'UNAVAILABLE'
        $storySealCount = $null
    } elseif ($null -ne $chapters) {
        if ($chapters -isnot [pscustomobject]) {
            $storyStatus = 'UNAVAILABLE'
            $storySealCount = $null
        } else {
            $chapterProperty = $chapters.PSObject.Properties['lost_herbarium_pages']
            foreach ($chapterCandidate in @($chapters.PSObject.Properties)) {
                $claimedCandidate = Get-JsonPropertyValue -Object $chapterCandidate.Value -Name 'claimed'
                if ($claimedCandidate -is [bool] -and $claimedCandidate) {
                    $storySealCount += 1
                }
            }
            if ($null -ne $chapterProperty) {
                $claimed = Get-JsonPropertyValue -Object $chapterProperty.Value -Name 'claimed'
                if ($claimed -isnot [bool]) {
                    $storyStatus = 'UNAVAILABLE'
                    $storySealCount = $null
                } elseif ($claimed) {
                    $storyStatus = 'CLAIMED'
                } elseif ($activeStoryId -eq 'lost_herbarium_pages') {
                    # Readiness is derived from several fields and the catalog;
                    # the audit intentionally reports the safe stored subset.
                    $storyStatus = 'ACTIVE_OR_READY'
                } else {
                    $storyStatus = 'LOCKED'
                }
            }
        }
    }

    $snapshot.Status = 'CAPTURED'
    $snapshot.Schema = $schema
    $snapshot.Coins = $coins
    $snapshot.Xp = $xp
    $snapshot.PlantSlotCount = $plants.Count
    $snapshot.OccupiedCount = $occupiedCount
    $snapshot.StoryChapterStatus = $storyStatus
    $snapshot.StorySealCount = $storySealCount
    return [pscustomobject]$snapshot
}

function Format-SnapshotValue {
    param([object]$Value)
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return 'NONE'
    }
    return [string]$Value
}

function Write-SemanticSaveSnapshot {
    param([pscustomobject]$Snapshot, [string]$FileName)
    $lines = @(
        "SNAPSHOT_LABEL=$($Snapshot.Label)",
        "STATUS=$($Snapshot.Status)",
        "SCHEMA=$(Format-SnapshotValue $Snapshot.Schema)",
        "COINS=$(Format-SnapshotValue $Snapshot.Coins)",
        "XP=$(Format-SnapshotValue $Snapshot.Xp)",
        "PLANT_SLOT_COUNT=$(Format-SnapshotValue $Snapshot.PlantSlotCount)",
        "OCCUPIED_COUNT=$(Format-SnapshotValue $Snapshot.OccupiedCount)",
        "STORY_CHAPTER_STATUS=$(Format-SnapshotValue $Snapshot.StoryChapterStatus)",
        "STORY_SEAL_COUNT=$(Format-SnapshotValue $Snapshot.StorySealCount)"
    )
    [System.IO.File]::WriteAllLines((Join-Path $outputRoot $FileName), $lines, [System.Text.UTF8Encoding]::new($false))
}

function Wait-PostLaunchSemanticSaveSnapshot {
    $deadline = [DateTime]::UtcNow.AddSeconds(20)
    do {
        $snapshot = Get-SemanticSaveSnapshot -Label 'POST_INSTALL_AFTER_LAUNCH'
        if ($snapshot.Status -eq 'CAPTURED' -and [int64]$snapshot.Schema -eq $expectedSaveSchema) {
            return $snapshot
        }
        if ($snapshot.Status -in @('NOT_INSTALLED', 'NOT_DEBUGGABLE', 'INVALID_JSON', 'UNSAFE_STRUCTURE')) {
            return $snapshot
        }
        Start-Sleep -Seconds 2
    } while ([DateTime]::UtcNow -lt $deadline)
    return $snapshot
}

function Compare-SemanticSaveSnapshots {
    param([pscustomobject]$Before, [pscustomobject]$After, [bool]$WasCleared)
    $bothCaptured = $Before.Status -eq 'CAPTURED' -and $After.Status -eq 'CAPTURED'
    $coinsPreserved = $bothCaptured -and [int64]$Before.Coins -eq [int64]$After.Coins
    $xpPreserved = $bothCaptured -and [int64]$Before.Xp -eq [int64]$After.Xp
    $slotsPreserved = $bothCaptured -and [int64]$Before.PlantSlotCount -eq [int64]$After.PlantSlotCount
    $occupiedPreserved = $bothCaptured -and [int64]$Before.OccupiedCount -eq [int64]$After.OccupiedCount
    $coreStatus = if ($WasCleared) {
        'CLEARED_BY_EXPLICIT_REQUEST'
    } elseif (-not $bothCaptured) {
        'NOT_EVALUATED'
    } elseif ($coinsPreserved -and $xpPreserved -and $slotsPreserved -and $occupiedPreserved) {
        'PASSED'
    } else {
        'MISMATCH'
    }
    $schemaTransition = if ($bothCaptured) { "$($Before.Schema)_TO_$($After.Schema)" } else { 'NOT_EVALUATED' }
    $comparison = [pscustomobject]@{
        Status = $coreStatus
        SchemaTransition = $schemaTransition
        CoinsPreserved = if ($bothCaptured) { ConvertTo-LowerBoolean $coinsPreserved } else { 'NOT_EVALUATED' }
        XpPreserved = if ($bothCaptured) { ConvertTo-LowerBoolean $xpPreserved } else { 'NOT_EVALUATED' }
        PlantSlotsPreserved = if ($bothCaptured) { ConvertTo-LowerBoolean $slotsPreserved } else { 'NOT_EVALUATED' }
        OccupiedPreserved = if ($bothCaptured) { ConvertTo-LowerBoolean $occupiedPreserved } else { 'NOT_EVALUATED' }
    }
    $lines = @(
        "PRE_INSTALL_STATUS=$($Before.Status)",
        "POST_INSTALL_STATUS=$($After.Status)",
        "SCHEMA_TRANSITION=$schemaTransition",
        "EXPECTED_POST_SCHEMA=$expectedSaveSchema",
        "COINS_PRESERVED=$($comparison.CoinsPreserved)",
        "XP_PRESERVED=$($comparison.XpPreserved)",
        "PLANT_SLOT_COUNT_PRESERVED=$($comparison.PlantSlotsPreserved)",
        "OCCUPIED_COUNT_PRESERVED=$($comparison.OccupiedPreserved)",
        "CORE_PROGRESS_STATUS=$coreStatus",
        "STORY_CHAPTER_STATUS_BEFORE=$(Format-SnapshotValue $Before.StoryChapterStatus)",
        "STORY_CHAPTER_STATUS_AFTER=$(Format-SnapshotValue $After.StoryChapterStatus)",
        "STORY_SEAL_COUNT_BEFORE=$(Format-SnapshotValue $Before.StorySealCount)",
        "STORY_SEAL_COUNT_AFTER=$(Format-SnapshotValue $After.StorySealCount)",
        'STORY_COMPARISON=INFORMATIONAL_PHASE93_STATE_MAY_BE_ADDED_BY_MIGRATION'
    )
    [System.IO.File]::WriteAllLines((Join-Path $outputRoot 'save-semantic-comparison.txt'), $lines, [System.Text.UTF8Encoding]::new($false))
    return $comparison
}

function Get-AndroidRuntimeState {
    $power = Invoke-Adb -Arguments @('shell', 'dumpsys', 'power')
    $windowPolicy = Invoke-Adb -Arguments @('shell', 'dumpsys', 'window', 'policy')
    $activities = Invoke-Adb -Arguments @('shell', 'dumpsys', 'activity', 'activities')
    $pidOutput = ''
    try {
        $pidOutput = Invoke-Adb -Arguments @('shell', 'pidof', $packageName)
    } catch {
        # A stopped process is a valid pre-launch state, not an ADB failure.
        $pidOutput = ''
    }

    $awake = $power -match '(?im)\bmWakefulness\s*=\s*Awake\b|\bWakefulness\s*:\s*Awake\b'
    # AOSP exposes mInteractive; HyperOS/Xiaomi exposes the equivalent HAL flag.
    # Wakefulness and keyguard are still checked independently, so a dozing or
    # locked device cannot pass through this compatibility branch.
    $interactive = $power -match '(?im)\bmInteractive\s*=\s*true\b|\bmHalInteractiveModeEnabled\s*=\s*true\b'
    $keyguardTruePattern = '(?im)^\s*(?:showing|mKeyguardShowing|isStatusBarKeyguard|mShowingLockscreen)\s*=\s*true\b|\bmDreamingLockscreen\s*=\s*true\b'
    $keyguardFalsePattern = '(?im)^\s*(?:showing|mKeyguardShowing|isStatusBarKeyguard|mShowingLockscreen)\s*=\s*false\b'
    $keyguardShowing = $windowPolicy -match $keyguardTruePattern
    $keyguardKnown = $keyguardShowing -or ($windowPolicy -match $keyguardFalsePattern)
    if (-not $keyguardKnown) {
        # Unknown lock state must never be treated as an unlocked phone.
        $keyguardShowing = $true
    }

    $pidMatch = [regex]::Match($pidOutput.Trim(), '^\d+(?:\s+\d+)*$')
    $appPid = if ($pidMatch.Success) { ($pidOutput.Trim() -split '\s+')[0] } else { '' }
    $processRunning = [bool]$appPid
    $escapedPackageName = [regex]::Escape($packageName)
    $foregroundPattern = '(?im)^\s*(?:mResumedActivity|topResumedActivity|ResumedActivity)\s*[:=][^\r\n]*\b' + $escapedPackageName + '(?:/|\b)'
    $foreground = $activities -match $foregroundPattern

    return [pscustomobject]@{
        UtcEpoch = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        Awake = [bool]$awake
        Interactive = [bool]$interactive
        KeyguardKnown = [bool]$keyguardKnown
        KeyguardShowing = [bool]$keyguardShowing
        ProcessRunning = [bool]$processRunning
        Foreground = [bool]$foreground
        Pid = $appPid
    }
}

function Format-SanitizedState {
    param([pscustomobject]$State)
    return @(
        "UTC_EPOCH=$($State.UtcEpoch)",
        "AWAKE=$(ConvertTo-LowerBoolean $State.Awake)",
        "INTERACTIVE=$(ConvertTo-LowerBoolean $State.Interactive)",
        "KEYGUARD_KNOWN=$(ConvertTo-LowerBoolean $State.KeyguardKnown)",
        "KEYGUARD_SHOWING=$(ConvertTo-LowerBoolean $State.KeyguardShowing)",
        "PROCESS_RUNNING=$(ConvertTo-LowerBoolean $State.ProcessRunning)",
        "FOREGROUND=$(ConvertTo-LowerBoolean $State.Foreground)",
        "PID=$(if ($State.Pid) { $State.Pid } else { 'NONE' })"
    )
}

function Write-SanitizedState {
    param([pscustomobject]$State, [string]$FileName)
    [System.IO.File]::WriteAllLines(
        (Join-Path $outputRoot $FileName),
        (Format-SanitizedState -State $State),
        [System.Text.UTF8Encoding]::new($false)
    )
}

function ConvertTo-SafeEvidenceLine {
    param([string]$Line, [int]$MaximumLength = 500)
    $safe = ($Line -replace '[\x00-\x1F\x7F]', ' ').Trim()
    if ($safe.Length -gt $MaximumLength) {
        $safe = $safe.Substring(0, $MaximumLength) + '...'
    }
    return $safe
}

function Get-PackageScopedEvidenceLines {
    param([string]$RawText, [int]$MaximumLines = 100)
    $result = [System.Collections.Generic.List[string]]::new()
    foreach ($line in ($RawText -split "`r?`n")) {
        if ($line -notmatch [regex]::Escape($packageName)) {
            continue
        }
        $safe = ConvertTo-SafeEvidenceLine -Line $line
        if ($safe) {
            $result.Add($safe)
        }
        if ($result.Count -ge $MaximumLines) {
            break
        }
    }
    return $result.ToArray()
}

function Write-PackageScopedEvidence {
    param([string]$Kind, [string]$QueryStatus, [string[]]$Lines, [string]$FileName)
    $output = [System.Collections.Generic.List[string]]::new()
    $output.Add("EVIDENCE_KIND=$Kind")
    $output.Add("PACKAGE=$packageName")
    $output.Add("QUERY_STATUS=$QueryStatus")
    $output.Add("MATCH_COUNT=$($Lines.Count)")
    for ($index = 0; $index -lt $Lines.Count; $index += 1) {
        $output.Add(('MATCH_{0:D3}={1}' -f ($index + 1), $Lines[$index]))
    }
    [System.IO.File]::WriteAllLines((Join-Path $outputRoot $FileName), $output, [System.Text.UTF8Encoding]::new($false))
}

function Get-FirstEvidenceValue {
    param([string]$RawText, [string]$Pattern)
    $match = [regex]::Match($RawText, $Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Multiline)
    if (-not $match.Success) {
        return 'NOT_REPORTED'
    }
    return ConvertTo-SafeEvidenceLine -Line $match.Groups[1].Value -MaximumLength 64
}

function Get-BatteryPowerSource {
    param([string]$AcPowered, [string]$UsbPowered, [string]$WirelessPowered, [string]$DockPowered)
    $reported = @($AcPowered, $UsbPowered, $WirelessPowered, $DockPowered) | Where-Object { $_ -ne 'NOT_REPORTED' }
    if ($reported.Count -eq 0) {
        return 'NOT_REPORTED'
    }
    $active = [System.Collections.Generic.List[string]]::new()
    if ($AcPowered -eq 'true') { $active.Add('AC') }
    if ($UsbPowered -eq 'true') { $active.Add('USB') }
    if ($WirelessPowered -eq 'true') { $active.Add('WIRELESS') }
    if ($DockPowered -eq 'true') { $active.Add('DOCK') }
    if ($active.Count -eq 0) {
        return 'NONE'
    }
    return ($active -join '+')
}

function Get-BatterySummaryLines {
    param([string]$RawText)
    $acPowered = Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*AC powered:\s*(true|false)\s*$'
    $usbPowered = Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*USB powered:\s*(true|false)\s*$'
    $wirelessPowered = Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*Wireless powered:\s*(true|false)\s*$'
    $dockPowered = Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*Dock powered:\s*(true|false)\s*$'
    return @(
        "STATUS=$(Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*status:\s*(\d+)\s*$')",
        "HEALTH=$(Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*health:\s*(\d+)\s*$')",
        "PRESENT=$(Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*present:\s*(true|false)\s*$')",
        "LEVEL_PERCENT=$(Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*level:\s*(\d+)\s*$')",
        "SCALE=$(Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*scale:\s*(\d+)\s*$')",
        "TEMPERATURE_TENTHS_C=$(Get-FirstEvidenceValue -RawText $RawText -Pattern '^\s*temperature:\s*(-?\d+)\s*$')",
        "AC_POWERED=$acPowered",
        "USB_POWERED=$usbPowered",
        "WIRELESS_POWERED=$wirelessPowered",
        "DOCK_POWERED=$dockPowered",
        "POWER_SOURCE=$(Get-BatteryPowerSource -AcPowered $acPowered -UsbPowered $usbPowered -WirelessPowered $wirelessPowered -DockPowered $dockPowered)"
    )
}

function Get-ThermalSummaryLines {
    param([string]$RawText)
    $status = Get-FirstEvidenceValue -RawText $RawText -Pattern '\b(?:Thermal Status|mStatus)\s*[=:]\s*([A-Z_]+|\d+)'
    $temperatures = [System.Collections.Generic.List[double]]::new()
    foreach ($match in [regex]::Matches($RawText, '\b(?:mValue|temperature|value)\s*[=:]\s*(-?\d+(?:\.\d+)?)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        $parsed = 0.0
        if ([double]::TryParse($match.Groups[1].Value, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$parsed) -and -not [double]::IsNaN($parsed) -and -not [double]::IsInfinity($parsed)) {
            $temperatures.Add($parsed)
        }
    }
    $maxTemperature = if ($temperatures.Count -gt 0) { [Math]::Round(($temperatures | Measure-Object -Maximum).Maximum, 2).ToString([System.Globalization.CultureInfo]::InvariantCulture) } else { 'NOT_REPORTED' }
    return @(
        "THERMAL_STATUS=$status",
        "TEMPERATURE_READING_COUNT=$($temperatures.Count)",
        "MAX_REPORTED_TEMPERATURE_C=$maxTemperature"
    )
}

function Write-DeviceHealthSummary {
    param([string]$BatteryRaw, [string]$ThermalRaw, [string]$BatteryFile, [string]$ThermalFile)
    [System.IO.File]::WriteAllLines((Join-Path $outputRoot $BatteryFile), (Get-BatterySummaryLines -RawText $BatteryRaw), [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllLines((Join-Path $outputRoot $ThermalFile), (Get-ThermalSummaryLines -RawText $ThermalRaw), [System.Text.UTF8Encoding]::new($false))
}

function Write-AuditReport {
    param(
        [string]$AuditState,
        [string]$TechnicalStatus,
        [string]$Reason,
        [int]$FatalCount = 0,
        [string]$CrashEvidenceStatus = 'NOT_EVALUATED',
        [string]$GfxStatus = 'NOT_EVALUATED',
        [string]$SaveStatus = 'NOT_EVALUATED',
        [string]$SemanticStatus = 'NOT_EVALUATED',
        [string]$SchemaTransition = 'NOT_EVALUATED',
        [int]$NotificationMatchCount = 0,
        [int]$AlarmMatchCount = 0,
        [int]$SampleCount = 0,
        [double]$ForegroundPercent = 0.0
    )
    $report = @(
        "# Bazal’s Pocket Garden Android device audit",
        '',
        "- UTC run: $timestamp",
        "- Device serial: $Serial",
        "- Package: $packageName",
        "- Installed version: $installedVersionName ($installedVersionCode)",
        "- Expected APK SHA-256: $expectedApkSha256",
        "- Installed APK SHA-256: $installedApkSha256",
        "- APK identity gate: $apkIdentityStatus",
        "- Expected save schema: $expectedSaveSchema",
        "- Sample duration: $SampleSeconds seconds",
        "- Audit state: $AuditState",
        "- Automated crash/ANR gate: $TechnicalStatus",
        "- Package crash evidence: $CrashEvidenceStatus",
        "- Matching fatal findings: $FatalCount",
        "- Valid runtime samples: $SampleCount",
        "- Foreground sample ratio: $([Math]::Round($ForegroundPercent, 1))%",
        "- Graphics frame telemetry: $GfxStatus",
        "- Save schema verification: $SaveStatus",
        "- Stable save fields across install: $SemanticStatus",
        "- Save schema transition: $SchemaTransition",
        "- Package notification evidence lines: $NotificationMatchCount",
        "- Package alarm evidence lines: $AlarmMatchCount",
        "- Evaluation note: $Reason",
        '',
        'An INVALID audit was not exercised under valid conditions and must not be reported as a pass or failure.',
        'UNAVAILABLE_NATIVE_GL means Android gfxinfo exposed no frame data for the native Godot surface; it is not a performance pass.',
        '',
        '## Manual acceptance',
        '',
        "- [ ] $installedVersionName installed over the previous build without losing the existing save.",
        '- [ ] Safe area around the camera, text and all touch targets are readable and reachable.',
        '- [ ] Vertical scrolling works in Storage, Shop, Measurement and Grower Journal; horizontal tab swipe still works outside their scroll areas.',
        '- [ ] A `.htgbackup` file can be exported through the Android document picker.',
        '- [ ] Import shows the expected level, coins and occupied pots before confirmation.',
        '- [ ] Confirmed import restores progress after an intentional in-game change and survives an app restart.',
        '- [ ] The first `ZAČÍT NOVOU HRU` tap only arms the warning; only `OPRAVDU ZAČÍT ZNOVU` resets progress.',
        '- [ ] After a confirmed new game, `OBNOVIT PŘEDCHOZÍ HRU` shows the old level, coins and occupied pots before confirmation.',
        '- [ ] Confirmed `POTVRDIT NÁVRAT` restores the previous game and that restored progress survives an app restart.',
        '- [ ] Cancelling the document picker does not show a false offline-return summary.',
        '- [ ] Background/resume, save reload and the full first cycle work.',
        '- [ ] In Care Center tap `OVĚŘIT UPOZORNĚNÍ ZA 20 S`, přejdi na plochu and confirm that the test notification arrives.',
        '- [ ] Tapping the care notification opens the exact referenced pot, or Storage when its harvest is ready.',
        '- [ ] Android Back closes a modal first, then returns plant detail to the room, then returns a secondary tab to Plants, and only then exits.',
        '- [ ] Plant detail contains no speed or pause controls; the real-time card shows an approximate ETA and closing/reopening the app advances by actual elapsed time.',
        '- [ ] A normal care notification is delivered after closing the app and remains scheduled after a phone reboot.',
        '- [ ] Animation remains comfortable throughout the audit.',
        '- [ ] Battery change and the sanitized thermal summary were reviewed; drain and heat remain acceptable.',
        '',
        'Manual boxes require a human observation and are never auto-approved by this script.',
        'Package, notification, alarm, logcat, battery and thermal artifacts contain only explicit package-scoped or fixed scalar evidence; whole-phone dumps and raw saves are never persisted.',
        ''
    )
    [System.IO.File]::WriteAllLines((Join-Path $outputRoot 'report.md'), $report, [System.Text.UTF8Encoding]::new($false))
}

function Stop-InvalidAudit {
    param([string]$Reason)
    [System.IO.File]::WriteAllLines(
        (Join-Path $outputRoot 'audit-status.txt'),
        @('AUDIT_STATE=INVALID', 'TECHNICAL_GATE=NOT_EVALUATED', "REASON=$Reason"),
        [System.Text.UTF8Encoding]::new($false)
    )
    Write-AuditReport -AuditState 'INVALID' -TechnicalStatus 'NOT_EVALUATED' -Reason $Reason
    Write-Output 'ANDROID_AUDIT_STATE=INVALID'
    Write-Output 'ANDROID_CAPTURE_VALIDITY=INVALID'
    Write-Output 'ANDROID_TECHNICAL_GATE=NOT_EVALUATED'
    Write-Output 'ANDROID_BACKUP_MANUAL_GATE=PENDING'
    Write-Output 'ANDROID_NOTIFICATION_MANUAL_GATE=PENDING'
    Write-Output 'ANDROID_BATTERY_THERMAL_MANUAL_GATE=PENDING'
    Write-Output "ANDROID_AUDIT_REPORT=$(Join-Path $outputRoot 'report.md')"
    exit 2
}

Write-Output "ANDROID_AUDIT_DEVICE=$Serial"
Write-Output "ANDROID_AUDIT_ARTIFACTS=$outputRoot"
Write-Output "ANDROID_EXPECTED_VERSION=$expectedVersionName"
Write-Output "ANDROID_EXPECTED_VERSION_CODE=$expectedVersionCode"
Write-Output "ANDROID_EXPECTED_SAVE_SCHEMA=$expectedSaveSchema"
$deviceProperties = @(
    "MODEL=$(ConvertTo-SafeEvidenceLine ((Invoke-Adb -Arguments @('shell', 'getprop', 'ro.product.model')).Trim()) -MaximumLength 120)",
    "MANUFACTURER=$(ConvertTo-SafeEvidenceLine ((Invoke-Adb -Arguments @('shell', 'getprop', 'ro.product.manufacturer')).Trim()) -MaximumLength 120)",
    "SDK_INT=$(ConvertTo-SafeEvidenceLine ((Invoke-Adb -Arguments @('shell', 'getprop', 'ro.build.version.sdk')).Trim()) -MaximumLength 16)",
    "PRIMARY_ABI=$(ConvertTo-SafeEvidenceLine ((Invoke-Adb -Arguments @('shell', 'getprop', 'ro.product.cpu.abi')).Trim()) -MaximumLength 64)",
    "BUILD_TYPE=$(ConvertTo-SafeEvidenceLine ((Invoke-Adb -Arguments @('shell', 'getprop', 'ro.build.type')).Trim()) -MaximumLength 32)"
)
[System.IO.File]::WriteAllLines((Join-Path $outputRoot 'device-properties.txt'), $deviceProperties, [System.Text.UTF8Encoding]::new($false))
Invoke-Adb -Arguments @('shell', 'wm', 'size') -OutputFile 'display-size.txt' | Out-Null
Invoke-Adb -Arguments @('shell', 'wm', 'density') -OutputFile 'display-density.txt' | Out-Null

# Capture stable progression scalars before adb install -r. The raw JSON exists
# only in memory inside Get-SemanticSaveSnapshot and is cleared after parsing.
$preInstallSnapshot = Get-SemanticSaveSnapshot -Label 'PRE_INSTALL'
Write-SemanticSaveSnapshot -Snapshot $preInstallSnapshot -FileName 'save-semantic-pre-install.txt'
Write-Output "ANDROID_SAVE_PRE_INSTALL_SNAPSHOT=$($preInstallSnapshot.Status)"

if ($Install) {
    $installOutput = Invoke-Adb -Arguments @('install', '-r', $ApkPath) -OutputFile 'install.txt'
    if ($installOutput -notmatch 'Success') {
        throw "APK installation failed.`n$installOutput"
    }
    Write-Output 'ANDROID_APK_INSTALL=PASSED'
    if ($ClearAppData) {
        Invoke-Adb -Arguments @('shell', 'pm', 'clear', $packageName) -OutputFile 'clear-app-data.txt' | Out-Null
        Write-Output 'ANDROID_APP_DATA_CLEARED=true'
    } else {
        Write-Output 'ANDROID_APP_DATA_PRESERVED=true'
    }
}

$packagePathProbe = Invoke-AdbPrivate -Arguments @('shell', 'pm', 'path', $packageName)
if (-not $packagePathProbe.Success -or $packagePathProbe.Output -notmatch 'package:') {
    throw "Package $packageName is not installed. Re-run with -Install."
}
$baseApkPathMatch = [regex]::Match($packagePathProbe.Output, '(?im)^package:(/[A-Za-z0-9._/+=~:-]+/base\.apk)\s*$')
if (-not $baseApkPathMatch.Success) {
    throw 'Installed base APK path could not be parsed safely.'
}
$installedBaseApkPath = $baseApkPathMatch.Groups[1].Value
$packagePathProbe.Output = ''

# dumpsys package can include a Package Queries section naming unrelated apps.
# Keep its stdout in memory only and persist a strict scalar allowlist below.
$packageMetadataProbe = Invoke-AdbPrivate -Arguments @('shell', 'dumpsys', 'package', $packageName)
if (-not $packageMetadataProbe.Success) {
    throw "Package metadata could not be read for $packageName."
}
$installedVersionNameMatch = [regex]::Match($packageMetadataProbe.Output, '(?m)^\s*versionName=([A-Za-z0-9][A-Za-z0-9._+-]{0,63})\s*$')
$installedVersionCodeMatch = [regex]::Match($packageMetadataProbe.Output, '(?m)^\s*versionCode=(\d+)\b')
if (-not $installedVersionNameMatch.Success -or -not $installedVersionCodeMatch.Success) {
    $packageMetadataProbe.Output = ''
    throw 'Installed package version metadata could not be parsed safely.'
}
$installedVersionName = $installedVersionNameMatch.Groups[1].Value
$installedVersionCode = $installedVersionCodeMatch.Groups[1].Value
$installedVersionNameMatch = $null
$installedVersionCodeMatch = $null
$runAsMetadataProbe = Invoke-AdbPrivate -Arguments @('shell', 'run-as', $packageName, 'id')
$packageDebuggable = [bool]$runAsMetadataProbe.Success
$packageMetadataProbe.Output = ''
$runAsMetadataProbe.Output = ''
if ($installedVersionName -ne $expectedVersionName -or $installedVersionCode -ne $expectedVersionCode) {
    throw "Installed package version mismatch. Expected $expectedVersionName ($expectedVersionCode), found $installedVersionName ($installedVersionCode)."
}

$installedHashProbe = Invoke-AdbPrivate -Arguments @('shell', 'sha256sum', $installedBaseApkPath)
if (-not $installedHashProbe.Success) {
    $installedHashProbe = Invoke-AdbPrivate -Arguments @('shell', 'toybox', 'sha256sum', $installedBaseApkPath)
}
$installedHashMatch = if ($installedHashProbe.Success) { [regex]::Match($installedHashProbe.Output, '(?im)^\s*([0-9a-f]{64})\s+\S+\s*$') } else { $null }
$installedApkSha256 = if ($null -ne $installedHashMatch -and $installedHashMatch.Success) { $installedHashMatch.Groups[1].Value.ToUpperInvariant() } else { 'UNAVAILABLE' }
$installedHashProbe.Output = ''
$apkIdentityStatus = if ($expectedApkSha256 -eq 'NOT_PROVIDED') {
    if ($installedApkSha256 -eq 'UNAVAILABLE') { 'UNAVAILABLE' } else { 'INSTALLED_ONLY' }
} elseif ($installedApkSha256 -eq 'UNAVAILABLE') {
    'UNAVAILABLE'
} elseif ($installedApkSha256 -eq $expectedApkSha256) {
    'PASSED'
} else {
    'MISMATCH'
}

$packageMetadata = @(
    'METADATA_SCOPE=REQUESTED_PACKAGE_SCALARS_ONLY',
    "PACKAGE=$packageName",
    "VERSION_NAME=$installedVersionName",
    "VERSION_CODE=$installedVersionCode",
    "DEBUG_RUN_AS_AVAILABLE=$(ConvertTo-LowerBoolean $packageDebuggable)",
    'BASE_APK_PATH_PERSISTED=false'
)
[System.IO.File]::WriteAllLines((Join-Path $outputRoot 'package-metadata.txt'), $packageMetadata, [System.Text.UTF8Encoding]::new($false))
$apkIdentity = @(
    "PACKAGE=$packageName",
    "EXPECTED_VERSION_NAME=$expectedVersionName",
    "EXPECTED_VERSION_CODE=$expectedVersionCode",
    "INSTALLED_VERSION_NAME=$installedVersionName",
    "INSTALLED_VERSION_CODE=$installedVersionCode",
    "EXPECTED_APK_SHA256=$expectedApkSha256",
    "INSTALLED_APK_SHA256=$installedApkSha256",
    "STATUS=$apkIdentityStatus"
)
[System.IO.File]::WriteAllLines((Join-Path $outputRoot 'apk-identity.txt'), $apkIdentity, [System.Text.UTF8Encoding]::new($false))
Write-Output "ANDROID_INSTALLED_VERSION=$installedVersionName"
Write-Output "ANDROID_INSTALLED_VERSION_CODE=$installedVersionCode"
Write-Output "ANDROID_EXPECTED_APK_SHA256=$expectedApkSha256"
Write-Output "ANDROID_INSTALLED_APK_SHA256=$installedApkSha256"
Write-Output "ANDROID_APK_IDENTITY_GATE=$apkIdentityStatus"
Write-Output "ANDROID_APK_SHA256=$expectedApkSha256"

$preflightState = Get-AndroidRuntimeState
Write-SanitizedState -State $preflightState -FileName 'preflight-state.txt'
if (-not $preflightState.Awake -or -not $preflightState.Interactive -or -not $preflightState.KeyguardKnown -or $preflightState.KeyguardShowing) {
    Stop-InvalidAudit -Reason 'PRECHECK_REQUIRES_AWAKE_INTERACTIVE_UNLOCKED_DEVICE'
}

Invoke-Adb -Arguments @('logcat', '-c') | Out-Null
Invoke-Adb -Arguments @('shell', 'dumpsys', 'gfxinfo', $packageName, 'reset') | Out-Null
if (-not $SkipLaunch) {
    try {
        $launchOutput = Invoke-Adb -Arguments @('shell', 'monkey', '-p', $packageName, '-c', 'android.intent.category.LAUNCHER', '1') -OutputFile 'launch.txt'
    } catch {
        Stop-InvalidAudit -Reason 'LAUNCHER_COMMAND_FAILED'
    }
    if ($launchOutput -notmatch 'Events injected: 1') {
        Stop-InvalidAudit -Reason 'LAUNCHER_EVENT_NOT_ACCEPTED'
    }
}
$postLaunchDeadline = [DateTime]::UtcNow.AddSeconds(10)
$postLaunchState = $null
do {
    Start-Sleep -Seconds 1
    $postLaunchState = Get-AndroidRuntimeState
    if ($postLaunchState.Awake -and $postLaunchState.Interactive -and $postLaunchState.KeyguardKnown -and -not $postLaunchState.KeyguardShowing -and $postLaunchState.ProcessRunning -and $postLaunchState.Foreground) {
        break
    }
} while ([DateTime]::UtcNow -lt $postLaunchDeadline)
Write-SanitizedState -State $postLaunchState -FileName 'post-launch-state.txt'
if (-not $postLaunchState.Awake -or -not $postLaunchState.Interactive -or -not $postLaunchState.KeyguardKnown -or $postLaunchState.KeyguardShowing -or -not $postLaunchState.ProcessRunning -or -not $postLaunchState.Foreground) {
    Stop-InvalidAudit -Reason 'LAUNCHER_DID_NOT_REACH_UNLOCKED_FOREGROUND_APP'
}

# The migration is allowed up to 20 seconds to reach the 15-second autosave.
# This probe finishes before the player is asked to touch the game, so coins,
# XP and occupancy comparisons cannot be contaminated by manual actions.
$postInstallSnapshot = Wait-PostLaunchSemanticSaveSnapshot
Write-SemanticSaveSnapshot -Snapshot $postInstallSnapshot -FileName 'save-semantic-post-install.txt'
$semanticComparison = Compare-SemanticSaveSnapshots -Before $preInstallSnapshot -After $postInstallSnapshot -WasCleared ([bool]$ClearAppData)
Write-Output "ANDROID_SAVE_POST_INSTALL_SNAPSHOT=$($postInstallSnapshot.Status)"
Write-Output "ANDROID_SAVE_SEMANTIC_COMPARISON=$($semanticComparison.Status)"
Write-Output "ANDROID_SAVE_SCHEMA_TRANSITION=$($semanticComparison.SchemaTransition)"

$observedSaveSchema = ''
$saveStatus = if ($packageDebuggable) { 'UNAVAILABLE' } else { 'NOT_SUPPORTED' }
if ($packageDebuggable) {
    if ($postInstallSnapshot.Status -eq 'CAPTURED') {
        $observedSaveSchema = [string]$postInstallSnapshot.Schema
        $saveStatus = if ([int]$postInstallSnapshot.Schema -eq $expectedSaveSchema) { 'PASSED' } else { 'MISMATCH' }
    } elseif ($postInstallSnapshot.Status -eq 'NOT_FOUND') {
        $saveStatus = 'NOT_FOUND'
    } else {
        $saveStatus = 'UNAVAILABLE'
    }
}
$saveVerification = @(
    "EXPECTED_SCHEMA=$expectedSaveSchema",
    "OBSERVED_SCHEMA=$(if ($observedSaveSchema) { $observedSaveSchema } else { 'NONE' })",
    "STATUS=$saveStatus"
)
[System.IO.File]::WriteAllLines((Join-Path $outputRoot 'save-verification.txt'), $saveVerification, [System.Text.UTF8Encoding]::new($false))
Write-Output "ANDROID_SAVE_SCHEMA_GATE=$saveStatus"

Write-Output "ANDROID_SAMPLE_SECONDS=$SampleSeconds"
Write-Output 'ANDROID_MANUAL_ACTION=Play the full first cycle, test all four tabs and both swipe directions now.'
$deadline = [DateTime]::UtcNow.AddSeconds($SampleSeconds)
$samples = [System.Collections.Generic.List[string]]::new()
$runtimeStates = [System.Collections.Generic.List[object]]::new()
while ([DateTime]::UtcNow -lt $deadline) {
    $runtimeState = Get-AndroidRuntimeState
    $runtimeStates.Add($runtimeState)
    $mem = (Invoke-Adb -Arguments @('shell', 'dumpsys', 'meminfo', $packageName)) -replace "`r?`n", ' | '
    $thermalRaw = Invoke-Adb -Arguments @('shell', 'dumpsys', 'thermalservice')
    $batteryRaw = Invoke-Adb -Arguments @('shell', 'dumpsys', 'battery')
    $sampleLines = @(
        (Format-SanitizedState -State $runtimeState),
        "MEMORY=$mem"
    )
    $sampleLines += @(Get-BatterySummaryLines -RawText $batteryRaw | ForEach-Object { "BATTERY_$_" })
    $sampleLines += @(Get-ThermalSummaryLines -RawText $thermalRaw | ForEach-Object { "THERMAL_$_" })
    $sampleLines += ''
    $samples.Add(($sampleLines | ForEach-Object { $_ }) -join [Environment]::NewLine)
    Start-Sleep -Seconds 5
}
[System.IO.File]::WriteAllLines((Join-Path $outputRoot 'samples.txt'), $samples, [System.Text.UTF8Encoding]::new($false))
$sampleCount = $runtimeStates.Count
$invalidUnlockedSamples = @($runtimeStates | Where-Object {
    -not $_.Awake -or -not $_.Interactive -or -not $_.KeyguardKnown -or $_.KeyguardShowing -or -not $_.ProcessRunning
}).Count
$foregroundCount = @($runtimeStates | Where-Object { $_.Foreground }).Count
$foregroundPercent = if ($sampleCount -gt 0) { 100.0 * $foregroundCount / $sampleCount } else { 0.0 }
$runtimeConditionsValid = $sampleCount -gt 0 -and $invalidUnlockedSamples -eq 0 -and $foregroundPercent -ge 80.0

Invoke-Adb -Arguments @('shell', 'dumpsys', 'gfxinfo', $packageName) -OutputFile 'gfxinfo.txt' | Out-Null
Invoke-Adb -Arguments @('shell', 'dumpsys', 'meminfo', $packageName) -OutputFile 'memory-final.txt' | Out-Null
$batteryFinalRaw = Invoke-Adb -Arguments @('shell', 'dumpsys', 'battery')
$thermalFinalRaw = Invoke-Adb -Arguments @('shell', 'dumpsys', 'thermalservice')
Write-DeviceHealthSummary -BatteryRaw $batteryFinalRaw -ThermalRaw $thermalFinalRaw -BatteryFile 'battery-final.txt' -ThermalFile 'thermal-final.txt'

# Notification and alarm services have no reliable package-only dumpsys mode on
# every supported Android version. Query in memory, use Android's default
# notification redaction, and persist only lines that name this package.
$notificationProbe = Invoke-AdbPrivate -Arguments @('shell', 'dumpsys', 'notification')
$alarmProbe = Invoke-AdbPrivate -Arguments @('shell', 'dumpsys', 'alarm')
$notificationLines = if ($notificationProbe.Success) { @(Get-PackageScopedEvidenceLines -RawText $notificationProbe.Output) } else { @() }
$alarmLines = if ($alarmProbe.Success) { @(Get-PackageScopedEvidenceLines -RawText $alarmProbe.Output) } else { @() }
$notificationQueryStatus = if ($notificationProbe.Success) { 'AVAILABLE' } else { 'UNAVAILABLE' }
$alarmQueryStatus = if ($alarmProbe.Success) { 'AVAILABLE' } else { 'UNAVAILABLE' }
Write-PackageScopedEvidence -Kind 'REDACTED_NOTIFICATION_PACKAGE_LINES' -QueryStatus $notificationQueryStatus -Lines $notificationLines -FileName 'notifications-package.txt'
Write-PackageScopedEvidence -Kind 'ALARM_PACKAGE_LINES' -QueryStatus $alarmQueryStatus -Lines $alarmLines -FileName 'alarms-package.txt'
$notificationMatchCount = $notificationLines.Count
$alarmMatchCount = $alarmLines.Count
Write-Output "ANDROID_NOTIFICATION_PACKAGE_MATCHES=$notificationMatchCount"
Write-Output "ANDROID_ALARM_PACKAGE_MATCHES=$alarmMatchCount"
Write-Output "ANDROID_NOTIFICATION_EVIDENCE_STATUS=$notificationQueryStatus"
Write-Output "ANDROID_ALARM_EVIDENCE_STATUS=$alarmQueryStatus"
$notificationProbe.Output = ''
$alarmProbe.Output = ''

# Never persist a complete logcat. Inspect only app-PID logs plus package-named
# ActivityManager crash/ANR lines, then store a fixed-size sanitized finding list.
$fatalPattern = 'FATAL EXCEPTION|ANR in com\.howtogrow\.game|Process com\.howtogrow\.game .* has died|Godot.*SCRIPT ERROR|Godot.*Parse Error'
$fatalFindings = [System.Collections.Generic.List[string]]::new()
$auditedPids = [System.Collections.Generic.SortedSet[string]]::new()
$successfulPidLogQueries = 0
if ($postLaunchState.Pid) {
    $auditedPids.Add([string]$postLaunchState.Pid) | Out-Null
}
foreach ($runtimeState in $runtimeStates) {
    if ($runtimeState.Pid) {
        $auditedPids.Add([string]$runtimeState.Pid) | Out-Null
    }
}
foreach ($auditPid in $auditedPids) {
    $pidLogProbe = Invoke-AdbPrivate -Arguments @('logcat', '-d', '-v', 'threadtime', "--pid=$auditPid")
    if ($pidLogProbe.Success) {
        $successfulPidLogQueries += 1
        foreach ($match in [regex]::Matches($pidLogProbe.Output, $fatalPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            if ($fatalFindings.Count -lt 100) {
                $fatalFindings.Add((ConvertTo-SafeEvidenceLine -Line $match.Value -MaximumLength 300))
            }
        }
    }
    $pidLogProbe.Output = ''
}
$activityLogProbe = Invoke-AdbPrivate -Arguments @('logcat', '-d', '-v', 'threadtime', 'ActivityManager:I', '*:S')
if ($activityLogProbe.Success) {
    $systemPackagePattern = 'ANR in com\.howtogrow\.game|Process com\.howtogrow\.game .* has died'
    foreach ($match in [regex]::Matches($activityLogProbe.Output, $systemPackagePattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        if ($fatalFindings.Count -lt 100) {
            $fatalFindings.Add((ConvertTo-SafeEvidenceLine -Line $match.Value -MaximumLength 300))
        }
    }
}
$crashEvidenceStatus = if ($successfulPidLogQueries -gt 0 -and $activityLogProbe.Success) { 'AVAILABLE' } else { 'UNAVAILABLE' }
$activityLogProbe.Output = ''
$logcatEvidence = [System.Collections.Generic.List[string]]::new()
$logcatEvidence.Add("PACKAGE=$packageName")
$logcatEvidence.Add("AUDITED_PID_COUNT=$($auditedPids.Count)")
$logcatEvidence.Add("SUCCESSFUL_PID_QUERY_COUNT=$successfulPidLogQueries")
$logcatEvidence.Add("CRASH_EVIDENCE_STATUS=$crashEvidenceStatus")
$logcatEvidence.Add("FATAL_FINDING_COUNT=$($fatalFindings.Count)")
for ($findingIndex = 0; $findingIndex -lt $fatalFindings.Count; $findingIndex += 1) {
    $logcatEvidence.Add(('FINDING_{0:D3}={1}' -f ($findingIndex + 1), $fatalFindings[$findingIndex]))
}
[System.IO.File]::WriteAllLines((Join-Path $outputRoot 'logcat-findings.txt'), $logcatEvidence, [System.Text.UTF8Encoding]::new($false))

$gfxinfo = Get-Content -LiteralPath (Join-Path $outputRoot 'gfxinfo.txt') -Raw
$totalFramesMatch = [regex]::Match($gfxinfo, '(?im)^\s*Total frames rendered:\s*(\d+)\s*$')
if ($totalFramesMatch.Success -and [int64]$totalFramesMatch.Groups[1].Value -eq 0) {
    $gfxStatus = 'UNAVAILABLE_NATIVE_GL'
} elseif ($totalFramesMatch.Success) {
    $gfxStatus = 'AVAILABLE'
} else {
    $gfxStatus = 'NOT_REPORTED'
}
Write-Output "ANDROID_GFXINFO_STATUS=$gfxStatus"

$saveSchemaVerified = -not $packageDebuggable -or $saveStatus -eq 'PASSED'
$semanticProgressVerified = $semanticComparison.Status -ne 'MISMATCH'
$apkIdentityVerified = $installedApkSha256 -ne 'UNAVAILABLE' -and ($expectedApkSha256 -eq 'NOT_PROVIDED' -or $apkIdentityStatus -eq 'PASSED')
$technicalStatus = if ($crashEvidenceStatus -eq 'AVAILABLE' -and $fatalFindings.Count -eq 0 -and $apkIdentityVerified -and $saveSchemaVerified -and $semanticProgressVerified) { 'PASSED' } else { 'FAILED' }
$runtimeStatus = if ($runtimeConditionsValid) { 'VALID' } else { 'INVALID' }
$auditState = if (-not $runtimeConditionsValid) { 'INVALID' } elseif ($technicalStatus -eq 'FAILED') { 'FAILED' } else { 'CAPTURED' }
$evaluationStatus = if ($runtimeConditionsValid) { $technicalStatus } else { 'NOT_EVALUATED' }
$evaluationReason = if ($invalidUnlockedSamples -gt 0) {
    'ONE_OR_MORE_SAMPLES_WERE_LOCKED_ASLEEP_NON_INTERACTIVE_OR_PROCESS_STOPPED'
} elseif ($foregroundPercent -lt 80.0) {
    'APP_FOREGROUND_RATIO_BELOW_80_PERCENT'
} elseif ($fatalFindings.Count -gt 0) {
    'CRASH_ANR_OR_GODOT_ERROR_DETECTED'
} elseif ($crashEvidenceStatus -ne 'AVAILABLE') {
    'PACKAGE_CRASH_EVIDENCE_COULD_NOT_BE_CAPTURED'
} elseif ($installedApkSha256 -eq 'UNAVAILABLE') {
    'INSTALLED_APK_SHA256_COULD_NOT_BE_CAPTURED'
} elseif ($apkIdentityStatus -eq 'MISMATCH') {
    'INSTALLED_APK_SHA256_MISMATCH'
} elseif ($saveStatus -eq 'MISMATCH') {
    'INSTALLED_APP_SAVE_SCHEMA_MISMATCH'
} elseif (-not $saveSchemaVerified) {
    'DEBUG_SAVE_SCHEMA_COULD_NOT_BE_VERIFIED'
} elseif ($semanticComparison.Status -eq 'MISMATCH') {
    'STABLE_SAVE_FIELDS_CHANGED_ACROSS_INSTALL'
} else {
    'AUTOMATED_CAPTURE_COMPLETED'
}
[System.IO.File]::WriteAllLines(
    (Join-Path $outputRoot 'audit-status.txt'),
    @(
        "AUDIT_STATE=$auditState",
        "CAPTURE_VALIDITY=$runtimeStatus",
        "RUNTIME_GATE=$runtimeStatus",
        "TECHNICAL_GATE=$evaluationStatus",
        "CRASH_EVIDENCE_STATUS=$crashEvidenceStatus",
        "APK_IDENTITY_GATE=$apkIdentityStatus",
        "EXPECTED_APK_SHA256=$expectedApkSha256",
        "INSTALLED_APK_SHA256=$installedApkSha256",
        "SAVE_SCHEMA_GATE=$saveStatus",
        "SAVE_SEMANTIC_GATE=$($semanticComparison.Status)",
        "SAVE_SCHEMA_TRANSITION=$($semanticComparison.SchemaTransition)",
        "NOTIFICATION_PACKAGE_MATCHES=$notificationMatchCount",
        "ALARM_PACKAGE_MATCHES=$alarmMatchCount",
        "NOTIFICATION_QUERY_STATUS=$notificationQueryStatus",
        "ALARM_QUERY_STATUS=$alarmQueryStatus",
        "SAMPLE_COUNT=$sampleCount",
        "UNLOCKED_INTERACTIVE_SAMPLES=$($sampleCount - $invalidUnlockedSamples)",
        "FOREGROUND_PERCENT=$([Math]::Round($foregroundPercent, 1))",
        "REASON=$evaluationReason"
    ),
    [System.Text.UTF8Encoding]::new($false)
)
Write-AuditReport -AuditState $auditState -TechnicalStatus $evaluationStatus -Reason $evaluationReason -FatalCount $fatalFindings.Count -CrashEvidenceStatus $crashEvidenceStatus -GfxStatus $gfxStatus -SaveStatus $saveStatus -SemanticStatus $semanticComparison.Status -SchemaTransition $semanticComparison.SchemaTransition -NotificationMatchCount $notificationMatchCount -AlarmMatchCount $alarmMatchCount -SampleCount $sampleCount -ForegroundPercent $foregroundPercent
# On Windows a daemon first spawned under redirected child-process output may
# inherit that pipe and keep the parent automation waiting after this script has
# already finished its report.  Device state and app data are unaffected by
# stopping the host-side daemon; the next adb command restarts it on demand.
if (-not $KeepAdbServer) {
	$previousErrorActionPreference = $ErrorActionPreference
	try {
		$ErrorActionPreference = 'Continue'
		& $AdbPath kill-server 2>&1 | Out-Null
	} finally {
		$ErrorActionPreference = $previousErrorActionPreference
	}
	Write-Output 'ADB_SERVER_LIFECYCLE=STOPPED_AFTER_AUDIT'
} else {
	Write-Output 'ADB_SERVER_LIFECYCLE=KEPT_BY_REQUEST'
}
Write-Output "ANDROID_AUDIT_STATE=$auditState"
Write-Output "ANDROID_CAPTURE_VALIDITY=$(if ($runtimeConditionsValid) { 'VALID' } else { 'INVALID' })"
Write-Output "ANDROID_RUNTIME_GATE=$runtimeStatus"
Write-Output "ANDROID_TECHNICAL_GATE=$evaluationStatus"
Write-Output 'ANDROID_BACKUP_MANUAL_GATE=PENDING'
Write-Output 'ANDROID_NOTIFICATION_MANUAL_GATE=PENDING'
Write-Output 'ANDROID_BATTERY_THERMAL_MANUAL_GATE=PENDING'
Write-Output "ANDROID_AUDIT_REPORT=$(Join-Path $outputRoot 'report.md')"
if ($auditState -eq 'INVALID') {
    exit 2
}
if ($auditState -eq 'FAILED') {
    exit 1
}
Write-Output 'ANDROID_DEVICE_AUDIT=CAPTURED'
