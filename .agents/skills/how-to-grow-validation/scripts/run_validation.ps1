param(
    [string]$ProjectRoot = '',
    [string]$GodotPath = '',
    [string]$PythonPath = '',
    [string]$OutputRoot = '',
    [switch]$SkipTests,
    [switch]$SkipCapture,
    [switch]$ReportOnly
)

$ErrorActionPreference = 'Stop'
$scriptRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$skillRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $scriptRoot))

function Resolve-ProjectRoot {
    param([string]$ExplicitRoot)
    if ($ExplicitRoot) {
        $resolved = [System.IO.Path]::GetFullPath($ExplicitRoot)
        if (-not (Test-Path -LiteralPath (Join-Path $resolved 'project.godot'))) {
            throw "The explicit project root does not contain project.godot: $resolved"
        }
        return $resolved
    }
    $candidate = $skillRoot
    while ($candidate) {
        if (Test-Path -LiteralPath (Join-Path $candidate 'project.godot')) {
            return $candidate
        }
        $parent = Split-Path -Parent $candidate
        if (-not $parent -or $parent -eq $candidate) {
            break
        }
        $candidate = $parent
    }
    throw 'Could not locate project.godot. Pass -ProjectRoot explicitly.'
}

function Resolve-GodotPath {
    param([string]$ExplicitPath, [string]$ResolvedProjectRoot)
    $candidates = @()
    if ($ExplicitPath) { $candidates += $ExplicitPath }
    if ($env:HOW_TO_GROW_GODOT) { $candidates += $env:HOW_TO_GROW_GODOT }
    $candidates += (Join-Path (Split-Path -Parent $ResolvedProjectRoot) 'Godot_v4.7-stable_win64.exe')
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }
    foreach ($commandName in @('godot4', 'godot')) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    throw 'Godot 4.7 was not found. Pass -GodotPath or set HOW_TO_GROW_GODOT.'
}

function Resolve-PythonPath {
    param([string]$ExplicitPath)
    if ($ExplicitPath) {
        if (-not (Test-Path -LiteralPath $ExplicitPath)) {
            throw "Python executable not found: $ExplicitPath"
        }
        return [System.IO.Path]::GetFullPath($ExplicitPath)
    }
    $command = Get-Command python -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    throw 'Python with Pillow was not found. Pass the Codex bundled Python via -PythonPath.'
}

$resolvedProjectRoot = Resolve-ProjectRoot -ExplicitRoot $ProjectRoot
$resolvedGodotPath = Resolve-GodotPath -ExplicitPath $GodotPath -ResolvedProjectRoot $resolvedProjectRoot
$resolvedPythonPath = Resolve-PythonPath -ExplicitPath $PythonPath

& $resolvedPythonPath -c 'from PIL import Image'
if ($LASTEXITCODE -ne 0) {
    throw 'The selected Python cannot import Pillow.'
}
Write-Output 'PILLOW_PREFLIGHT=PASSED'

if (-not $OutputRoot) {
    $timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
    $OutputRoot = Join-Path $resolvedProjectRoot ".godot\validation\$timestamp"
}
$resolvedOutputRoot = [System.IO.Path]::GetFullPath($OutputRoot)
[System.IO.Directory]::CreateDirectory($resolvedOutputRoot) | Out-Null

Write-Output "VALIDATION_PROJECT=$resolvedProjectRoot"
Write-Output "VALIDATION_GODOT=$resolvedGodotPath"
Write-Output "VALIDATION_PYTHON=$resolvedPythonPath"
Write-Output "VALIDATION_ARTIFACTS=$resolvedOutputRoot"
$testPassMarker = ''
$previousAppData = $env:APPDATA
$validationAppData = Join-Path $resolvedOutputRoot 'appdata'
[System.IO.Directory]::CreateDirectory($validationAppData) | Out-Null
$env:APPDATA = $validationAppData

try {
if (-not $SkipTests) {
    $testScript = Join-Path $resolvedProjectRoot 'tools\run_tests.ps1'
    if (-not (Test-Path -LiteralPath $testScript)) {
        throw "Missing project regression runner: $testScript"
    }
    $testOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $testScript -GodotPath $resolvedGodotPath 2>&1 | Out-String
    $testExitCode = $LASTEXITCODE
    $nativeTestLog = Join-Path $resolvedProjectRoot '.godot\mvp-tests.log'
    if (Test-Path -LiteralPath $nativeTestLog) {
        # Windows PowerShell 5.1 decodes BOM-less UTF-8 as ANSI. Read Godot's
        # native UTF-8 log explicitly so the audit artifact keeps Czech text.
        $testOutput = [System.IO.File]::ReadAllText(
            $nativeTestLog,
            [System.Text.UTF8Encoding]::new($false)
        )
    }
    [System.IO.File]::WriteAllText(
        (Join-Path $resolvedOutputRoot 'tests.log'),
        $testOutput,
        [System.Text.UTF8Encoding]::new($false)
    )
    Write-Output $testOutput
    if ($testExitCode -ne 0 -or $testOutput -notmatch 'MVP_TESTS_PASSED=\d+') {
        throw "Godot regression failed or did not emit MVP_TESTS_PASSED. Exit code: $testExitCode"
    }
    $testPassMarker = [regex]::Match($testOutput, 'MVP_TESTS_PASSED=\d+').Value
}

if (-not $SkipCapture) {
    $captureScript = 'res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd'
    $captureStdout = Join-Path $resolvedOutputRoot 'capture.stdout.log'
    $captureStderr = Join-Path $resolvedOutputRoot 'capture.stderr.log'
    $quotedOutputRoot = '"' + $resolvedOutputRoot + '"'
    $captureArguments = @(
        '--rendering-method', 'gl_compatibility',
        '--path', '.',
        '--script', $captureScript,
        '--',
        '--output-dir', $quotedOutputRoot
    )
    # Screenshot capture needs a real renderer. Do not add --headless here;
    # Godot's dummy texture storage cannot read the viewport image.
    $captureProcess = Start-Process `
        -FilePath $resolvedGodotPath `
        -WorkingDirectory $resolvedProjectRoot `
        -ArgumentList $captureArguments `
        -RedirectStandardOutput $captureStdout `
        -RedirectStandardError $captureStderr `
        -PassThru `
        -Wait `
        -WindowStyle Hidden
    $captureOutput = ''
    if (Test-Path -LiteralPath $captureStdout) {
        $captureOutput += [System.IO.File]::ReadAllText($captureStdout)
    }
    if (Test-Path -LiteralPath $captureStderr) {
        $captureOutput += [System.IO.File]::ReadAllText($captureStderr)
    }
    Write-Output $captureOutput
    if ($captureProcess.ExitCode -ne 0 -or $captureOutput -notmatch 'HOW_TO_GROW_CAPTURE=PASSED' -or $captureOutput -match 'SCRIPT ERROR|Parse Error') {
        throw "Deterministic capture failed. Exit code: $($captureProcess.ExitCode)"
    }
}
} finally {
    $env:APPDATA = $previousAppData
}

$diffScript = Join-Path $scriptRoot 'visual_diff.py'
$manifest = Join-Path $skillRoot 'references\visual-cases.json'
$diffArguments = @(
    $diffScript,
    '--project-root', $resolvedProjectRoot,
    '--artifacts', $resolvedOutputRoot,
    '--manifest', $manifest,
    '--output', $resolvedOutputRoot
)
if ($ReportOnly) {
    $diffArguments += '--report-only'
}
& $resolvedPythonPath @diffArguments
$diffExitCode = $LASTEXITCODE
if ($diffExitCode -ne 0) {
    throw "Visual validation failed. Exit code: $diffExitCode"
}

$validationReport = Join-Path $resolvedOutputRoot 'report.md'
$validationStatus = Join-Path $resolvedOutputRoot 'validation-status.txt'
$statusLines = [System.Collections.Generic.List[string]]::new()
if ($testPassMarker) {
    $statusLines.Add($testPassMarker)
} else {
    $statusLines.Add('MVP_TESTS_SKIPPED=true')
}
$statusLines.Add('HOW_TO_GROW_CAPTURE=PASSED')
$statusLines.Add('HOW_TO_GROW_VISUALS=PASSED')
$statusLines.Add('HOW_TO_GROW_VALIDATION=PASSED')
[System.IO.File]::WriteAllLines($validationStatus, $statusLines, [System.Text.UTF8Encoding]::new($false))

Write-Output "VALIDATION_REPORT=$validationReport"
Write-Output "VALIDATION_STATUS=$validationStatus"
Write-Output 'HOW_TO_GROW_VALIDATION=PASSED'
