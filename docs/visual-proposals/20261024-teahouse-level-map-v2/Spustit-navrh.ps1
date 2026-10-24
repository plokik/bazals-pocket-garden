$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = Join-Path $projectRoot 'tmp/teahouse-level-map-v2/interactive-appdata'
    [System.IO.Directory]::CreateDirectory($env:APPDATA) | Out-Null
    Start-Process -FilePath 'R:\_projekty\Godot_v4.7-stable_win64.exe' -WorkingDirectory $projectRoot -ArgumentList @('--path','.', '--log-file','res://tmp/teahouse-level-map-v2/interactive.log', '--script','res://docs/visual-proposals/20261024-teahouse-level-map-v2/prototype/review.gd') -WindowStyle Normal
} finally { $env:APPDATA = $previousAppData }
