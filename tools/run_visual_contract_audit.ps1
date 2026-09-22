param(
    [string]$GodotPath = ''
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
. (Join-Path $PSScriptRoot 'resolve_godot_executable.ps1')
$GodotPath = Resolve-HowToGrowGodotExecutable -ExplicitPath $GodotPath -ProjectRoot $projectRoot
$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmssZ')
$artifactRelative = ".godot/visual-contract/$timestamp"
$artifactDirectory = Join-Path $projectRoot ".godot\visual-contract\$timestamp"
[System.IO.Directory]::CreateDirectory($artifactDirectory) | Out-Null
$logPath = Join-Path $artifactDirectory 'visual-contract.log'
$logRelative = "$artifactRelative/visual-contract.log"
$importLogRelative = "$artifactRelative/asset-import.log"
$isolatedAppData = Join-Path $artifactDirectory 'appdata'
[System.IO.Directory]::CreateDirectory($isolatedAppData) | Out-Null
$previousAppData = $env:APPDATA
try {
    $env:APPDATA = $isolatedAppData
    $importArguments = @(
        '--headless',
        '--import',
        '--path', '.',
        '--log-file', $importLogRelative
    )
    $importProcess = Start-Process `
        -FilePath $GodotPath `
        -WorkingDirectory $projectRoot `
        -ArgumentList $importArguments `
        -PassThru `
        -Wait `
        -WindowStyle Hidden
    if ($importProcess.ExitCode -ne 0) {
        throw "Godot asset import failed before visual contract audit. Native exit code: $($importProcess.ExitCode)"
    }
    $godotArguments = @(
        '--headless',
        '--rendering-method', 'gl_compatibility',
        '--path', '.',
        '--log-file', $logRelative,
        '--script', 'res://tools/visual_contract_audit.gd',
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
Write-Output 'VISUAL_CONTRACT_ASSET_IMPORT=PASSED'
Write-Output $output
$forbidden = $output -match 'SCRIPT ERROR|Parse Error|VISUAL_CONTRACT_AUDIT=FAILED'
if ($process.ExitCode -ne 0 -or $forbidden -or $output -notmatch 'VISUAL_CONTRACT_AUDIT=PASSED') {
    throw "Visual contract audit failed with native exit code $($process.ExitCode)."
}
Write-Output "VISUAL_CONTRACT_ARTIFACTS=$artifactDirectory"
