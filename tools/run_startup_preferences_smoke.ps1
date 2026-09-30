param([string]$GodotPath = '')
$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
. (Join-Path $PSScriptRoot 'resolve_godot_executable.ps1')
$GodotPath = Resolve-HowToGrowGodotExecutable -ExplicitPath $GodotPath -ProjectRoot $projectRoot
$logPath = Join-Path $projectRoot '.godot\startup-preferences-smoke.log'
$isolatedAppData = Join-Path $projectRoot '.godot\startup-preferences-smoke\appdata'
[System.IO.Directory]::CreateDirectory($isolatedAppData) | Out-Null
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = $isolatedAppData
    # Also works on a fresh checkout without any existing imported PNGs/fonts.
    $importProcess = Start-Process -FilePath $GodotPath -WorkingDirectory $projectRoot `
        -ArgumentList @('--headless', '--import', '--path', '.', '--log-file', '.godot/startup-preferences-import.log') `
        -WindowStyle Hidden -PassThru -Wait
    if ($importProcess.ExitCode -ne 0) { throw 'Startup preference asset import failed.' }
    $process = Start-Process -FilePath $GodotPath -WorkingDirectory $projectRoot `
        -ArgumentList @('--headless', '--path', '.', '--script', 'res://tools/startup_preferences_smoke.gd', '--log-file', '.godot/startup-preferences-smoke.log') `
        -WindowStyle Hidden -PassThru -Wait
} finally { $env:APPDATA = $previousAppData }
$output = Get-Content -LiteralPath $logPath -Raw
Write-Output $output
if ($process.ExitCode -ne 0 -or $output -notmatch 'STARTUP_PREFERENCES_SMOKE=PASSED' -or $output -match 'SCRIPT ERROR|Parse Error') {
    throw 'Startup preference smoke failed.'
}
