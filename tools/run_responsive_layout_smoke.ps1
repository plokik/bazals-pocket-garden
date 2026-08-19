param(
    [string]$GodotPath = 'C:\_projekty\Godot_v4.7-stable_win64.exe'
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$artifactRelative = ".godot/responsive/$timestamp"
$artifactDirectory = Join-Path $projectRoot ".godot\responsive\$timestamp"
New-Item -ItemType Directory -Path $artifactDirectory -Force | Out-Null
$logPath = Join-Path $artifactDirectory 'responsive-layout.log'
$logRelative = "$artifactRelative/responsive-layout.log"
$isolatedAppData = Join-Path $artifactDirectory 'appdata'
New-Item -ItemType Directory -Path $isolatedAppData -Force | Out-Null
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = $isolatedAppData
    $godotArguments = @(
        '--rendering-method', 'gl_compatibility',
        '--path', '.',
        '--log-file', $logRelative,
        '--script', 'res://tools/responsive_layout_smoke.gd',
        '--', '--output-dir', $artifactRelative
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
if ($process.ExitCode -ne 0 -or $output -notmatch 'RESPONSIVE_LAYOUT_SMOKE=PASSED') {
    throw "Responsive layout smoke failed with native exit code $($process.ExitCode)."
}
Write-Output "RESPONSIVE_ARTIFACTS=$artifactDirectory"
