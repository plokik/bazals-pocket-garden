$ErrorActionPreference = 'Stop'
$proposalRoot = $PSScriptRoot
$repoRoot = [IO.Path]::GetFullPath((Join-Path $proposalRoot '../../..'))
$mirrorRoot = Join-Path $repoRoot 'tmp/cinematic-tutorial-20261019/project'
$taskGodot = Join-Path (Split-Path -Parent $repoRoot) 'Godot_v4.7-stable_win64.exe'
if (-not (Test-Path -LiteralPath (Join-Path $mirrorRoot 'project.godot'))) {
    throw 'Chybí izolovaná zkušební kopie projektu.'
}
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path $repoRoot 'tmp/cinematic-tutorial-20261019/interactive-user'
    New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
    # Visible review explicitly requested; uses no player profile.
    Start-Process -FilePath $taskGodot -WorkingDirectory $mirrorRoot -ArgumentList @(
        '--path','.',
        '--log-file','.godot/cinematic-interactive.log',
        '--script','res://docs/visual-proposals/20261019-cinematic-tutorial-v1/prototype/launch.gd'
    ) -Wait
} finally { $env:APPDATA = $previousAppData }
