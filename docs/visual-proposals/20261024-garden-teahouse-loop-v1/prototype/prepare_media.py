from pathlib import Path
import json
import re
import shutil
import subprocess
import hashlib
import math
import array

ROOT = next(p for p in Path(__file__).resolve().parents if (p/'project.godot').is_file())
QA = ROOT / 'tmp/garden-teahouse-loop-v1'
OUT = ROOT / 'docs/visual-proposals/20261024-garden-teahouse-loop-v1'
FF = Path('C:/Users/drikv/Documents/ChatGPT/How to grow_/output/cinematic-tutorial-20261019/.media-tools/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe')
data = json.loads((QA/'verification.json').read_text(encoding='utf-8'))
assert data['failures'] == 0 and data['checks'] == 48
log = (QA/'movie-v2.log').read_text(encoding='utf-8')
assert 'GARDEN_TEAHOUSE_REVIEW_CHECKS=48 FAILURES=0' in log and 'SCRIPT ERROR' not in log and '\nERROR:' not in log
layout = (QA/'layout.log').read_text(encoding='utf-8')
assert 'GARDEN_TEAHOUSE_LAYOUT_CHECKS=25 FAILURES=0' in layout
dry_time = next(e['time'] for e in data['events'] if e.get('label') == '03-drying')
dry_end = next(e['time'] for e in data['events'] if e.get('label') == '04-dry-herbs-after-time-cut')
(QA/'time-cut.txt').write_text('ČASOVÝ STŘIH · DOSUŠENO POZDĚJI',encoding='utf-8')
technical_trim = .8
enable = f'between(t,{dry_time-.4-technical_trim:.3f},{dry_end+1.5-technical_trim:.3f})'
video_filter = (
    f"drawbox=x=8:y=820:w=416:h=34:color=0x173123@0.94:t=fill:enable='{enable}',"
    "drawtext=fontfile='C\\:/Windows/Fonts/arialbd.ttf':textfile=tmp/garden-teahouse-loop-v1/time-cut.txt:"
    f"x=(w-tw)/2:y=829:fontsize=13:fontcolor=0xf2f5df:enable='{enable}'"
)
video = OUT/'cesta-bylinky-do-cajovny.mp4'
result = subprocess.run([str(FF),'-hide_banner','-y','-ss',str(technical_trim),'-i',str(QA/'gameplay-v2.avi'),'-vf',video_filter,
    '-c:v','libx264','-preset','medium','-crf','17','-pix_fmt','yuv420p',
    '-af','loudnorm=I=-20:TP=-4.5:LRA=9,alimiter=limit=0.75:level=false','-ar','48000','-c:a','aac','-b:a','192k','-movflags','+faststart',str(video)],cwd=ROOT,capture_output=True)
(QA/'encode.log').write_bytes(result.stderr)
assert result.returncode == 0, result.stderr.decode(errors='replace')[-2200:]
probe = subprocess.run([str(FF),'-hide_banner','-i',str(video)],capture_output=True)
probe_text = probe.stderr.decode(errors='replace')
assert '432x960' in probe_text and '30 fps' in probe_text and 'Audio: aac' in probe_text
decoded = subprocess.run([str(FF),'-v','error','-i',str(video),'-f','f32le','-ac','1','-ar','16000','-'],capture_output=True,check=True)
samples = array.array('f',decoded.stdout)
rms = math.sqrt(sum(float(v)**2 for v in samples)/len(samples))
peak = max(abs(v) for v in samples)
assert rms > .0001 and peak < 1.0
for name in ['01-order-offer','02-next-harvest','02b-plant-care','03-drying','04-dry-herbs-after-time-cut',
             '05-next-craft','06-crafted-tea','07-next-serve','08-teahouse-matching','09-pour','10-served',
             '11-next-delivery','12-reward','layout-360x640','layout-360x800','layout-432x960','layout-600x900']:
    shutil.copy2(QA/(name+'.png'),OUT/(name+'.png'))
shutil.copy2(QA/'verification.json',OUT/'gameplay-verification.json')
(OUT/'runtime-checks.txt').write_text(log,encoding='utf-8')
(OUT/'layout-checks.txt').write_text(layout,encoding='utf-8')
result = {'native_size':[432,960],'fps':30,'source':'Godot Movie Maker; real viewport input',
    'functional_review_checks':48,'layout_review_checks':25,'failures':0,
    'duration_driver':data['duration'],'technical_start_trim_seconds':technical_trim,'audio_rms':rms,'audio_peak':peak,
    'video_sha256':hashlib.sha256(video.read_bytes()).hexdigest(),
    'production_runtime_changed':False,'player_profile_changed':False,'serving_receipt_persisted':False,
    'approved_reference_changes':False,'physical_phone_tested':False,
    'time_cuts':[e for e in data['events'] if 'time_cut_offline_seconds' in e]}
(OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('REVIEW_MEDIA_READY='+str(video))
print('CHECKS=48+25 AUDIO_RMS='+str(round(rms,5))+' PEAK='+str(round(peak,5)))
