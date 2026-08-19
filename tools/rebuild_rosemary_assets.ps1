param(
    [string]$PythonPath = "python"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$comicDir = Join-Path $projectRoot "assets\plants\comic"
$rawDir = Join-Path $comicDir "raw_alpha_v2"
$source = Join-Path $comicDir "rosemary_family_sheet_chroma_v1.png"
$alpha = Join-Path $comicDir "rosemary_family_sheet_alpha_v2.png"

& $PythonPath (Join-Path $PSScriptRoot "remove_connected_chroma.py") `
    --input $source `
    --out $alpha `
    --key-color "#ed05f0" `
    --transparent-threshold 12 `
    --interior-key-threshold 64 `
    --opaque-threshold 220
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $PythonPath (Join-Path $PSScriptRoot "split_comic_plant_family.py") `
    --input $alpha `
    --out-dir $rawDir `
    --prefix "rosemary" `
    --column-cuts "420,790" `
    --row-cut 550 `
    --min-component-size 200
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$targets = [ordered]@{
    seed = 352
    sprout = 444
    young = 533
    mature = 620
    sick = 620
    harvest_ready = 620
}

foreach ($entry in $targets.GetEnumerator()) {
    $state = $entry.Key
    & $PythonPath (Join-Path $PSScriptRoot "normalize_comic_plant_sprite.py") `
        --input (Join-Path $rawDir "rosemary_${state}_raw_v1.png") `
        --out (Join-Path $comicDir "rosemary_${state}_v2.png") `
        --max-height $entry.Value `
        --fixed-scale 2
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Output "ROSEMARY_ASSETS_REBUILT output=$comicDir"
