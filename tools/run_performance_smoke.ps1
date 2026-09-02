param(
    [string]$GodotPath = ''
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
. (Join-Path $PSScriptRoot 'resolve_godot_executable.ps1')
$GodotPath = Resolve-HowToGrowGodotExecutable -ExplicitPath $GodotPath -ProjectRoot $projectRoot
$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$artifactRelative = ".godot/performance/$timestamp"
$artifactDirectory = Join-Path $projectRoot ".godot\performance\$timestamp"
New-Item -ItemType Directory -Path $artifactDirectory -Force | Out-Null
$logPath = Join-Path $artifactDirectory 'performance-smoke.log'
$logRelative = "$artifactRelative/performance-smoke.log"
$isolatedAppData = Join-Path $artifactDirectory 'appdata'
New-Item -ItemType Directory -Path $isolatedAppData -Force | Out-Null
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = $isolatedAppData
    $godotArguments = @(
        '--path', '.',
        '--log-file', $logRelative,
        '--script', 'res://tools/performance_smoke.gd',
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
if ($process.ExitCode -ne 0 -or $output -notmatch 'PERFORMANCE_SMOKE=PASSED') {
    throw "Performance smoke failed with native exit code $($process.ExitCode)."
}
Write-Output "PERFORMANCE_ARTIFACTS=$artifactDirectory"
