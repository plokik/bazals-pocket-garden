[CmdletBinding()]
param(
    [string]$GodotPath = '',
    [string]$PythonPath = '',
    [ValidateRange(1, 1000)]
    [int]$ExpectedSaveSchema = 41,
    [ValidateRange(1, 10000)]
    [int]$ExpectedMinimumRegressionTests = 6747,
    [ValidateRange(1, 1000)]
    [int]$ExpectedVisualCases = 54,
    [ValidateRange(1, 1000)]
    [int]$ExpectedActiveVisualGates = 34,
    [ValidatePattern('^[0-9A-Fa-f]{64}$')]
    [string]$ExpectedGoldenDigest = '77946B927604C1CB0C8D7931BD8FFC167E299C858C35B97D548FC07F691E7170',
    [switch]$FullVisualValidation
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$artifactDirectory = Join-Path $projectRoot ".godot\ci\$timestamp"
[System.IO.Directory]::CreateDirectory($artifactDirectory) | Out-Null

function Resolve-GodotExecutable {
    param([string]$ExplicitPath)

    $candidates = [System.Collections.Generic.List[string]]::new()
    if ($ExplicitPath) { $candidates.Add($ExplicitPath) }
    if ($env:HOW_TO_GROW_GODOT) { $candidates.Add($env:HOW_TO_GROW_GODOT) }
    $candidates.Add((Join-Path (Split-Path -Parent $projectRoot) 'Godot_v4.7-stable_win64.exe'))
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }
    foreach ($name in @('godot4', 'godot')) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    throw 'Godot 4.7 was not found. Pass -GodotPath or set HOW_TO_GROW_GODOT.'
}

function Resolve-PythonExecutable {
    param([string]$ExplicitPath, [bool]$Required)

    if ($ExplicitPath) {
        if (-not (Test-Path -LiteralPath $ExplicitPath -PathType Leaf)) {
            throw "Python executable not found: $ExplicitPath"
        }
        return [System.IO.Path]::GetFullPath($ExplicitPath)
    }
    if ($Required) {
        $command = Get-Command python -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
        throw 'Python with Pillow was not found. Pass -PythonPath for full visual validation.'
    }
    return ''
}

function Read-TextUtf8 {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
    return [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
}

function Unquote-Value {
    param([string]$Value)

    $trimmed = $Value.Trim()
    if ($trimmed.Length -ge 2 -and $trimmed[0] -eq '"' -and $trimmed[$trimmed.Length - 1] -eq '"') {
        return $trimmed.Substring(1, $trimmed.Length - 2)
    }
    return $trimmed
}

function Read-ExportPresets {
    param([string]$Path)

    $records = @{}
    $currentIndex = ''
    $currentSection = ''
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        if ($line -match '^\[preset\.(\d+)\]$') {
            $currentIndex = $Matches[1]
            $currentSection = 'preset'
            if (-not $records.ContainsKey($currentIndex)) { $records[$currentIndex] = @{} }
            continue
        }
        if ($line -match '^\[preset\.(\d+)\.options\]$') {
            $currentIndex = $Matches[1]
            $currentSection = 'options'
            if (-not $records.ContainsKey($currentIndex)) { $records[$currentIndex] = @{} }
            continue
        }
        if ($currentIndex -and $line -match '^([^=]+)=(.*)$') {
            $key = "$currentSection/$($Matches[1].Trim())"
            $records[$currentIndex][$key] = Unquote-Value -Value $Matches[2]
        }
    }
    return $records
}

function Get-RuntimeSourceFiles {
    $files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    $mainScene = Get-Item -LiteralPath (Join-Path $projectRoot 'main.tscn')
    $files.Add($mainScene)
    foreach ($directory in @('scripts', 'assets')) {
        $root = Join-Path $projectRoot $directory
        if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
        Get-ChildItem -LiteralPath $root -Recurse -File |
            Where-Object { $_.Extension -in @('.gd', '.tscn', '.tres', '.gdshader', '.theme') } |
            ForEach-Object { $files.Add($_) }
    }
    return @($files | Sort-Object FullName -Unique)
}

function Get-LiteralRuntimeReferences {
    param([System.IO.FileInfo[]]$Sources)

    $references = @{}
    $pattern = '["''](?<path>res://[^"'']+)["'']'
    foreach ($source in $Sources) {
        $content = Read-TextUtf8 -Path $source.FullName
        foreach ($match in [regex]::Matches($content, $pattern)) {
            $resourcePath = $match.Groups['path'].Value.Trim()
            $relativeCandidate = $resourcePath.Substring(6)
            if (
                $resourcePath -match '[%{}*\[\]()+?|\\]' -or
                $resourcePath.EndsWith('/') -or
                -not [System.IO.Path]::GetExtension($relativeCandidate)
            ) {
                continue
            }
            if (-not $references.ContainsKey($resourcePath)) {
                $references[$resourcePath] = [System.Collections.Generic.List[string]]::new()
            }
            $references[$resourcePath].Add($source.FullName)
        }
    }
    return $references
}

function Get-GoldenDigest {
    $manifestRelative = '.agents/skills/how-to-grow-validation/references/visual-cases.json'
    $manifestPath = Join-Path $projectRoot ($manifestRelative.Replace('/', '\'))
    $manifest = Read-TextUtf8 -Path $manifestPath | ConvertFrom-Json
    if (-not $manifest.cases) {
        throw "Visual manifest contains no cases: $manifestPath"
    }
    $caseCount = @($manifest.cases).Count
    $activeGateCount = @($manifest.cases | Where-Object { $_.gate -eq $true }).Count
    if ($caseCount -ne $ExpectedVisualCases) {
        throw "Visual case count changed unexpectedly: expected $ExpectedVisualCases, got $caseCount"
    }
    if ($activeGateCount -ne $ExpectedActiveVisualGates) {
        throw "Active visual gate count changed unexpectedly: expected $ExpectedActiveVisualGates, got $activeGateCount"
    }

    $paths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    [void]$paths.Add($manifestRelative)
    foreach ($case in $manifest.cases) {
        $reference = [string]$case.reference
        if (-not $reference) {
            throw "Visual case '$($case.id)' has no reference path."
        }
        [void]$paths.Add($reference.Replace('\', '/'))
    }

    $digestLines = [System.Collections.Generic.List[string]]::new()
    foreach ($relative in @($paths | Sort-Object)) {
        $absolute = Join-Path $projectRoot ($relative.Replace('/', '\'))
        if (-not (Test-Path -LiteralPath $absolute -PathType Leaf)) {
            throw "Golden reference is missing: $relative"
        }
        $hash = (Get-FileHash -LiteralPath $absolute -Algorithm SHA256).Hash
        $digestLines.Add("$relative|$hash")
    }

    $bytes = [System.Text.Encoding]::UTF8.GetBytes(($digestLines -join "`n"))
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '')
    } finally {
        $sha.Dispose()
    }
}

function Invoke-CheckedPowerShell {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [string[]]$Arguments,
        [string[]]$RequiredMarkers
    )

    if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) {
        throw "CI step $Name is missing its runner: $ScriptPath"
    }
    $safeName = $Name.ToLowerInvariant() -replace '[^0-9a-z]+', '-'
    $logPath = Join-Path $artifactDirectory "$safeName.log"
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $rawOutput = @(& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments 2>&1)
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    $output = ($rawOutput | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine
    if ($output) { $output += [Environment]::NewLine }
    [System.IO.File]::WriteAllText($logPath, $output, [System.Text.UTF8Encoding]::new($false))

    $missing = [System.Collections.Generic.List[string]]::new()
    $matched = [System.Collections.Generic.List[string]]::new()
    foreach ($marker in $RequiredMarkers) {
        $match = [regex]::Match($output, $marker)
        if ($match.Success) { $matched.Add($match.Value) } else { $missing.Add($marker) }
    }
    $forbiddenError = [regex]::IsMatch(
        $output,
        'SCRIPT ERROR|Parse Error|MVP TESTY SELHALY|VISUAL_CONTRACT_AUDIT=FAILED'
    )
    $stepKey = $Name.ToUpperInvariant() -replace '[^0-9A-Z]+', '_'
    if ($exitCode -ne 0 -or $missing.Count -gt 0 -or $forbiddenError) {
        Write-Output "CI_STEP_${stepKey}=FAILED"
        Write-Output "CI_STEP_LOG=$logPath"
        $tail = @($rawOutput | Select-Object -Last 160)
        if ($tail.Count -gt 0) { Write-Output ($tail -join [Environment]::NewLine) }
        throw "CI step $Name failed: exit=$exitCode missing=$($missing -join ',') forbidden_error=$forbiddenError"
    }
    Write-Output "CI_STEP_${stepKey}=PASSED"
    foreach ($value in $matched) { Write-Output $value }
    Write-Output "CI_STEP_LOG=$logPath"
}

$resolvedGodot = Resolve-GodotExecutable -ExplicitPath $GodotPath
$godotVersion = (& $resolvedGodot --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $godotVersion -notmatch '^4\.7(?:\.|-)') {
    throw "Godot 4.7 is required; '$resolvedGodot' reported '$godotVersion'."
}
Write-Output "CI_GODOT=$resolvedGodot"
Write-Output "CI_GODOT_VERSION=$godotVersion"
Write-Output "CI_ARTIFACTS=$artifactDirectory"

$resolvedPython = Resolve-PythonExecutable -ExplicitPath $PythonPath -Required ([bool]$FullVisualValidation)
if ($resolvedPython) {
    & $resolvedPython -c 'from PIL import Image'
    if ($LASTEXITCODE -ne 0) {
        throw "The selected Python cannot import Pillow: $resolvedPython"
    }
    Write-Output 'CI_PILLOW=PASSED'
}

$goldenBefore = Get-GoldenDigest
if ($goldenBefore -cne $ExpectedGoldenDigest.ToUpperInvariant()) {
    throw "Approved visual baseline digest changed. Expected $($ExpectedGoldenDigest.ToUpperInvariant()), got $goldenBefore"
}
Write-Output "CI_VISUAL_BASELINE=PASSED cases=$ExpectedVisualCases gates=$ExpectedActiveVisualGates digest=$goldenBefore"
$operationError = $null
try {
    $projectConfig = Read-TextUtf8 -Path (Join-Path $projectRoot 'project.godot')
    $mainSceneMatch = [regex]::Match($projectConfig, '(?m)^run/main_scene="(res://[^"]+)"$')
    $versionMatch = [regex]::Match($projectConfig, '(?m)^config/version="([^"]+)"$')
    if (-not $mainSceneMatch.Success -or -not $versionMatch.Success) {
        throw 'project.godot must declare run/main_scene and config/version.'
    }
    $projectVersion = $versionMatch.Groups[1].Value
    if ($projectVersion -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$') {
        throw "Project version is not a supported semantic version: $projectVersion"
    }
    $mainScenePath = Join-Path $projectRoot ($mainSceneMatch.Groups[1].Value.Substring(6).Replace('/', '\'))
    if (-not (Test-Path -LiteralPath $mainScenePath -PathType Leaf)) {
        throw "Configured main scene is missing: $($mainSceneMatch.Groups[1].Value)"
    }

    $sessionSource = Read-TextUtf8 -Path (Join-Path $projectRoot 'scripts\game_session.gd')
    $schemaMatch = [regex]::Match(
        $sessionSource,
        '(?m)^\s*const\s+SAVE_SCHEMA(?:\s*:\s*\w+)?\s*(?::=|=)\s*(\d+)\b'
    )
    if (-not $schemaMatch.Success) { throw 'Could not read SAVE_SCHEMA from scripts/game_session.gd.' }
    $saveSchema = [int]$schemaMatch.Groups[1].Value
    if ($saveSchema -ne $ExpectedSaveSchema) {
        throw "SAVE_SCHEMA changed unexpectedly: expected $ExpectedSaveSchema, got $saveSchema"
    }

    $presetPath = Join-Path $projectRoot 'export_presets.cfg'
    $presets = Read-ExportPresets -Path $presetPath
    $requiredPresetNames = @('Android', 'Android Release AAB', 'Android Emulator x86_64')
    if ($presets.Count -ne $requiredPresetNames.Count) {
        throw "Expected $($requiredPresetNames.Count) Android presets, found $($presets.Count)."
    }

    $versionCodes = [System.Collections.Generic.HashSet[string]]::new()
    $excludeFilters = [System.Collections.Generic.HashSet[string]]::new()
    $packageIds = [System.Collections.Generic.HashSet[string]]::new()
    $presetByName = @{}
    foreach ($index in @($presets.Keys | Sort-Object { [int]$_ })) {
        $preset = $presets[$index]
        $name = [string]$preset['preset/name']
        if (-not $name) { throw "Preset $index has no name." }
        $presetByName[$name] = $preset
        if ([string]$preset['preset/platform'] -ne 'Android') {
            throw "Preset '$name' is not an Android preset."
        }
        if ([string]$preset['preset/export_filter'] -ne 'all_resources') {
            throw "Preset '$name' must use export_filter=all_resources."
        }
        if ([string]$preset['preset/include_filter']) {
            throw "Preset '$name' must not use include_filter."
        }
        [void]$versionCodes.Add([string]$preset['options/version/code'])
        [void]$excludeFilters.Add([string]$preset['preset/exclude_filter'])
        [void]$packageIds.Add([string]$preset['options/package/unique_name'])
    }
    foreach ($name in $requiredPresetNames) {
        if (-not $presetByName.ContainsKey($name)) { throw "Required export preset is missing: $name" }
    }

    $parsedVersionCode = 0
    if (
        $versionCodes.Count -ne 1 -or
        -not [int]::TryParse([string]@($versionCodes)[0], [ref]$parsedVersionCode)
    ) {
        throw 'All Android presets must share one numeric version/code.'
    }
    $versionCode = $parsedVersionCode
    if ($versionCode -lt 1) { throw "Android version/code must be positive, got $versionCode" }
    if ($packageIds.Count -ne 1 -or -not @($packageIds)[0]) {
        throw 'All Android presets must share one non-empty package/unique_name.'
    }
    if ($excludeFilters.Count -ne 1) {
        throw 'All Android presets must use the same exclude_filter.'
    }
    foreach ($name in @('Android', 'Android Release AAB')) {
        if ([string]$presetByName[$name]['options/version/name'] -ne $projectVersion) {
            throw "Preset '$name' version/name does not match project version $projectVersion."
        }
    }
    if ([string]$presetByName['Android Emulator x86_64']['options/version/name'] -ne "$projectVersion-emulator") {
        throw "Emulator version/name must be '$projectVersion-emulator'."
    }

    $excludeFilter = [string]@($excludeFilters)[0]
    $excludePatterns = @(
        $excludeFilter.Split(',') |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ }
    )
    $requiredExclusions = @(
        'docs/**',
        'tests/**',
        'tools/**',
        'builds/**',
        'assets/ui/visual/**/source/**',
        'assets/ui/visual/phase167/**'
    )
    foreach ($required in $requiredExclusions) {
        if ($required -notin $excludePatterns) {
            throw "Required export exclusion is missing: $required"
        }
    }

    $runtimeSources = Get-RuntimeSourceFiles
    $runtimeReferences = Get-LiteralRuntimeReferences -Sources $runtimeSources
    $missingReferences = [System.Collections.Generic.List[string]]::new()
    $excludedReferences = [System.Collections.Generic.List[string]]::new()
    foreach ($resourcePath in @($runtimeReferences.Keys | Sort-Object)) {
        $relative = $resourcePath.Substring(6).Replace('\', '/')
        $absolute = Join-Path $projectRoot ($relative.Replace('/', '\'))
        $sourceList = @($runtimeReferences[$resourcePath])
        $referenceOnlyDesignPath = (
            $relative -like 'docs/visual-proposals/**' -and
            @(
                $sourceList |
                    Where-Object { -not $_.EndsWith('scripts\ui\visual_design_system.gd') }
            ).Count -eq 0
        )
        if (-not (Test-Path -LiteralPath $absolute -PathType Leaf)) {
            $sources = @(
                $sourceList |
                    ForEach-Object { $_.Substring($projectRoot.Length).TrimStart('\', '/') }
            )
            $missingReferences.Add("$resourcePath <- $($sources -join ', ')")
        }
        foreach ($pattern in $excludePatterns) {
            if ($relative -like $pattern -and -not $referenceOnlyDesignPath) {
                $excludedReferences.Add("$resourcePath matches $pattern")
                break
            }
        }
    }
    if ($missingReferences.Count -gt 0) {
        throw "Missing literal runtime assets:`n$($missingReferences -join "`n")"
    }
    if ($excludedReferences.Count -gt 0) {
        throw "Runtime assets are blocked by export exclusions:`n$($excludedReferences -join "`n")"
    }

    $staticLines = @(
        "version=$projectVersion",
        "version_code=$versionCode",
        "save_schema=$saveSchema",
        "package_id=$(@($packageIds)[0])",
        "preset_count=$($presets.Count)",
        "runtime_source_count=$($runtimeSources.Count)",
        "literal_runtime_reference_count=$($runtimeReferences.Count)",
        "golden_digest_before=$goldenBefore"
    )
    [System.IO.File]::WriteAllLines(
        (Join-Path $artifactDirectory 'static-contract.txt'),
        $staticLines,
        [System.Text.UTF8Encoding]::new($false)
    )
    Write-Output "CI_VERSION_CONTRACT=PASSED version=$projectVersion code=$versionCode schema=$saveSchema"
    Write-Output "CI_EXPORT_CONTRACT=PASSED presets=$($presets.Count)"
    Write-Output "CI_RUNTIME_ASSETS=PASSED references=$($runtimeReferences.Count)"
    Write-Output 'CI_STATIC_CONTRACT=PASSED'

    Invoke-CheckedPowerShell `
        -Name 'VISUAL_CONTRACT' `
        -ScriptPath (Join-Path $projectRoot 'tools\run_visual_contract_audit.ps1') `
        -Arguments @('-GodotPath', $resolvedGodot) `
        -RequiredMarkers @('VISUAL_CONTRACT_ASSET_IMPORT=PASSED', 'VISUAL_CONTRACT_AUDIT=PASSED')

    Invoke-CheckedPowerShell `
        -Name 'FULL_GDSCRIPT' `
        -ScriptPath (Join-Path $projectRoot 'tools\run_tests.ps1') `
        -Arguments @('-GodotPath', $resolvedGodot) `
        -RequiredMarkers @('(?m)^MVP_TESTS_PASSED=\d+\s*$')

    $regressionLogPath = Join-Path $artifactDirectory 'full-gdscript.log'
    $regressionOutput = Read-TextUtf8 -Path $regressionLogPath
    $regressionMatch = [regex]::Match($regressionOutput, '(?m)^MVP_TESTS_PASSED=(\d+)\s*$')
    if (-not $regressionMatch.Success) {
        throw "Could not read the complete regression count from $regressionLogPath"
    }
    $regressionCount = [int]$regressionMatch.Groups[1].Value
    if ($regressionCount -lt $ExpectedMinimumRegressionTests) {
        throw "Regression test count dropped: expected at least $ExpectedMinimumRegressionTests, got $regressionCount"
    }
    Write-Output "CI_REGRESSION_COUNT=PASSED count=$regressionCount minimum=$ExpectedMinimumRegressionTests"

    if ($FullVisualValidation) {
        Invoke-CheckedPowerShell `
            -Name 'FULL_VISUAL_VALIDATION' `
            -ScriptPath (Join-Path $projectRoot '.agents\skills\how-to-grow-validation\scripts\run_validation.ps1') `
            -Arguments @(
                '-ProjectRoot', $projectRoot,
                '-GodotPath', $resolvedGodot,
                '-PythonPath', $resolvedPython,
                '-OutputRoot', (Join-Path $artifactDirectory 'visual-validation')
            ) `
            -RequiredMarkers @('MVP_TESTS_PASSED=\d+', 'HOW_TO_GROW_VALIDATION=PASSED')
    }
} catch {
    $operationError = $_
}

$goldenAfter = Get-GoldenDigest
if ($goldenAfter -ne $goldenBefore) {
    throw "Golden references changed during CI validation. Before=$goldenBefore After=$goldenAfter"
}
Write-Output "CI_GOLDEN_READ_ONLY=PASSED digest=$goldenAfter"

if ($operationError) {
    throw $operationError
}
Write-Output 'HOW_TO_GROW_CI=PASSED'
