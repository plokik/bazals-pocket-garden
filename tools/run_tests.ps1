param(
    [string]$GodotPath = 'C:\_projekty\Godot_v4.7-stable_win64.exe'
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$logDirectory = Join-Path $projectRoot '.godot'
if (-not (Test-Path -LiteralPath $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory | Out-Null
}
$logPath = Join-Path $logDirectory 'mvp-tests.log'
$isolatedAppData = Join-Path $logDirectory ("test-appdata\" + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssfffZ'))
New-Item -ItemType Directory -Path $isolatedAppData -Force | Out-Null
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = $isolatedAppData
    $importArguments = @(
        '--headless',
        '--editor',
        '--path', '.',
        '--quit',
        '--log-file', '.godot/asset-import.log'
    )
    $importProcess = Start-Process `
        -FilePath $GodotPath `
        -WorkingDirectory $projectRoot `
        -ArgumentList $importArguments `
        -PassThru `
        -Wait `
        -WindowStyle Hidden
    if ($importProcess.ExitCode -ne 0) {
        throw "Godot asset import failed. Native exit code: $($importProcess.ExitCode)"
    }
    $godotArguments = @(
        '--headless',
        '--path', '.',
        '--log-file', '.godot/mvp-tests.log',
        '--script', 'res://tests/test_runner.gd'
    )
    $process = Start-Process `
        -FilePath $GodotPath `
        -WorkingDirectory $projectRoot `
        -ArgumentList $godotArguments `
        -PassThru `
        -Wait `
        -WindowStyle Hidden
} finally {
    $env:APPDATA = $previousAppData
}

$output = Get-Content -LiteralPath $logPath -Raw
Write-Output $output
if ($process.ExitCode -eq 0 -and
    $output -match 'MVP_TESTS_PASSED=\d+' -and
    $output -notmatch 'SCRIPT ERROR|Parse Error|MVP TESTY SELHALY') {
    exit 0
}
throw "Godot regression failed. Native exit code: $($process.ExitCode)"
