$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
$ffmpeg = 'C:\Users\drikv\Documents\ChatGPT\How to grow_\output\cinematic-tutorial-20261019\.media-tools\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe'
$frames = Join-Path $projectRoot 'tmp/teahouse-level-map-v3/film-frames-jpeg/%04d.jpg'
$outputPath = Join-Path $projectRoot 'docs/visual-proposals/20261024-teahouse-level-map-v3/cajovna-v3-animovany-navrh.mp4'
$music = Join-Path $projectRoot 'assets/audio/garden_v1/music/workshop.ogg'
$success = Join-Path $projectRoot 'assets/audio/garden_v1/sfx/craft_success.wav'
$sparkle = Join-Path $projectRoot 'assets/audio/garden_v1/sfx/sparkle.wav'
$mix = '[1:a]atrim=0:20,asetpts=PTS-STARTPTS,volume=0.12,afade=t=in:st=0:d=0.4,afade=t=out:st=18:d=2[m];[2:a]volume=0.55,adelay=10100|10100[s];[3:a]volume=0.35,adelay=14000|14000[t];[m][s][t]amix=inputs=3:normalize=0,alimiter=limit=0.85:level=false,atrim=0:20[a]'
& $ffmpeg -y -hide_banner -loglevel warning -framerate 30 -i $frames -i $music -i $success -i $sparkle -filter_complex $mix -map '0:v:0' -map '[a]' -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -movflags '+faststart' -r 30 -t 20 -c:a aac -b:a 192k -ar 48000 $outputPath
if ($LASTEXITCODE -ne 0) { throw 'Video encode failed' }
Write-Output 'TEAHOUSE_V3_FILM_ENCODE=PASSED'

