param([string]$GodotPath = '')
$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
. (Join-Path $PSScriptRoot 'resolve_godot_executable.ps1')
$GodotPath = Resolve-HowToGrowGodotExecutable -ExplicitPath $GodotPath -ProjectRoot $projectRoot
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
    foreach ($smoke in @(
        @{ Script = 'startup_preferences_smoke.gd'; Log = 'startup-preferences-smoke.log'; Marker = 'STARTUP_PREFERENCES_SMOKE=PASSED' },
        @{ Script = 'prepared_startup_assets_smoke.gd'; Log = 'prepared-startup-assets-smoke.log'; Marker = 'PREPARED_STARTUP_ASSETS=PASSED' }
    )) {
        $process = Start-Process -FilePath $GodotPath -WorkingDirectory $projectRoot `
            -ArgumentList @('--headless', '--path', '.', '--script', "res://tools/$($smoke.Script)", '--log-file', ".godot/$($smoke.Log)") `
            -WindowStyle Hidden -PassThru -Wait
        $output = Get-Content -LiteralPath (Join-Path $projectRoot ".godot/$($smoke.Log)") -Raw -Encoding UTF8
        Write-Output $output
        if ($process.ExitCode -ne 0 -or $output -notmatch [regex]::Escape($smoke.Marker) -or $output -match 'SCRIPT ERROR|Parse Error') {
            throw "Startup smoke failed: $($smoke.Script)"
        }
    }
} finally { $env:APPDATA = $previousAppData }
