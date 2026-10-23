$ErrorActionPreference = 'Stop'
$taskProposalRoot = $PSScriptRoot
$taskRepoRoot = [IO.Path]::GetFullPath((Join-Path $taskProposalRoot '../../..'))
$taskGodot = Join-Path (Split-Path -Parent $taskRepoRoot) 'Godot_v4.7-stable_win64.exe'
$taskPreviousAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path $taskRepoRoot '.godot/teahouse-products-20261017/interactive-user'
    New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
    # Visible interactive review window intentionally requested by this launcher.
    Start-Process -FilePath $taskGodot -WorkingDirectory $taskRepoRoot -ArgumentList @('--path', '.', '--script', 'res://docs/visual-proposals/20261017-teahouse-products-v1/prototype/launch.gd') -Wait
} finally { $env:APPDATA = $taskPreviousAppData }
