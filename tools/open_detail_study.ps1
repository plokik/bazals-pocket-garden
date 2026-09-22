param([string]$GodotPath = '')

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
. (Join-Path $PSScriptRoot 'resolve_godot_executable.ps1')
$GodotPath = Resolve-HowToGrowGodotExecutable -ExplicitPath $GodotPath -ProjectRoot $projectRoot
$runName = 'play-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssfffZ')
$isolatedData = Join-Path $projectRoot ('.godot\detail-study-appdata\' + $runName)
New-Item -ItemType Directory -Path $isolatedData -Force | Out-Null
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = $isolatedData
    $process = Start-Process -FilePath $GodotPath -WorkingDirectory $projectRoot `
        -ArgumentList @('--path', '.', '--log-file', ('.godot/detail-study-' + $runName + '.log'), '--script', 'res://tools/preview_detail_study.gd', '--', ('--output-dir=.godot/detail-study/' + $runName)) `
        -WindowStyle Normal -PassThru
} finally {
    $env:APPDATA = $previousAppData
}
Write-Output ('DETAIL_STUDY_PID=' + $process.Id)
Write-Output ('DETAIL_STUDY_LOG=' + (Join-Path $projectRoot ('.godot\detail-study-' + $runName + '.log')))
Write-Output 'The playable game uses a separate generated test garden. Close its window to finish.'
