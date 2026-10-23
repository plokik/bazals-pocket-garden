from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys

sys.path.insert(0,'C:/Users/drikv/Documents/ChatGPT/How to grow_/output/cinematic-tutorial-20261019/.media-tools')

import imageio_ffmpeg
import numpy as np
from PIL import Image, ImageDraw, ImageFont

REPO = Path(__file__).resolve().parents[4]
PROPOSAL = Path(__file__).resolve().parent.parent
MIRROR = REPO / 'tmp/cinematic-tutorial-20261019/project'
OUTPUT = Path('C:/Users/drikv/Documents/ChatGPT/How to grow_/output/cinematic-tutorial-20261019')
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
OUTPUT.mkdir(exist_ok=True, parents=True)
video = OUTPUT / 'bazal-filmovy-uvod-v2.mp4'
avi = OUTPUT / 'bazal-filmovy-uvod-v2.avi'
assert avi.is_file() and not video.exists()
subprocess.run([FFMPEG, '-hide_banner','-loglevel','error','-n','-i',str(avi),
                '-c:v','libx264','-preset','medium','-crf','18','-pix_fmt','yuv420p',
                '-c:a','aac','-b:a','160k','-ac','2','-movflags','+faststart',str(video)],check=True)
probe = subprocess.run([FFMPEG,'-hide_banner','-i',str(video)],capture_output=True,text=True)
duration_match = re.search(r'Duration: (\d+):(\d+):([\d.]+)',probe.stderr)
assert duration_match
duration = int(duration_match[1])*3600+int(duration_match[2])*60+float(duration_match[3])
assert 34 < duration < 40
decoded = subprocess.run([FFMPEG,'-v','error','-i',str(video),'-f','f32le','-ac','1','-ar','24000','-'],capture_output=True,check=True)
audio = np.frombuffer(decoded.stdout,dtype=np.float32)
peak = float(np.abs(audio).max())
rms = float(np.sqrt(np.mean(audio**2)))
assert np.isfinite(audio).all() and 0.001 < peak < 0.99 and rms > 1e-5
frames = OUTPUT / 'frames'
frames.mkdir(exist_ok=True)
times = [0.6,2.2,3.0,6.0,10.8,13.8,14.7,17.0,21.6,24.5,28.5,34.0]
for time in times:
    target = frames / f'{time:04.1f}.png'
    subprocess.run([FFMPEG,'-hide_banner','-loglevel','error','-y','-ss',str(time),'-i',str(video),
                    '-frames:v','1',str(target)],check=True)
font = ImageFont.truetype(str(REPO/'assets/fonts/Poppins-SemiBold.ttf'),16)
contact = Image.new('RGB',(4*216,3*508),'#102b20')
draw = ImageDraw.Draw(contact)
for index,time in enumerate(times):
    image = Image.open(frames/f'{time:04.1f}.png').convert('RGB')
    assert image.size == (432,960)
    image.thumbnail((216,480),Image.Resampling.LANCZOS)
    x,y = (index%4)*216,(index//4)*508
    contact.paste(image,(x,y))
    draw.text((x+8,y+482),f'{time:.1f} s',font=font,fill='#fff2cd')
contact.save(OUTPUT/'kontrola-scen.jpg',quality=93)
board = Image.new('RGB',(1296,1038),'#102b20')
draw = ImageDraw.Draw(board)
heading = ImageFont.truetype(str(REPO/'assets/fonts/Poppins-ExtraBold.ttf'),25)
draw.text((28,16),'BAZAL • FILMOVÝ ÚVOD BEZ DABINGU',font=heading,fill='#fff2cd')
for index,time in enumerate([6.0,13.8,28.5]):
    board.paste(Image.open(frames/f'{time:04.1f}.png').convert('RGB'),(index*432,70))
board.save(OUTPUT/'tri-sceny-ke-schvaleni.jpg',quality=95)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
manifest = json.loads((REPO/'.agents/skills/how-to-grow-validation/references/visual-cases.json').read_text(encoding='utf-8-sig'))
cases = manifest['cases']
reference_hashes = {}
for case in cases:
    name = case['reference']
    reference = REPO/name
    assert sha(reference) == sha(MIRROR/name), f'Reference changed: {name}'
    reference_hashes[name] = sha(reference)
source_hashes = {}
for name in ['scripts/main.gd','scripts/game_session.gd','scripts/ui/guided_tutorial.gd','project.godot']:
    assert sha(REPO/name) == sha(MIRROR/name), f'Production source changed: {name}'
    source_hashes[name] = sha(REPO/name)
native_log = (MIRROR/'.godot/cinematic-capture-final.log').read_text(encoding='utf-8')
assert 'CINEMATIC_NATIVE_REVIEW=PASSED' in native_log and not re.search(r'SCRIPT ERROR|Parse Error',native_log)
movie_log = (MIRROR/'.godot/cinematic-movie.log').read_text(encoding='utf-8')
assert 'CINEMATIC_MOVIE_COMPLETE=PASSED' in movie_log and not re.search(r'SCRIPT ERROR|Parse Error',movie_log)
tests_log = (MIRROR/'.godot/mvp-tests.log').read_text(encoding='utf-8')
assert 'MVP_TESTS_PASSED=7800' in tests_log
visual_report = json.loads((REPO/'tmp/cinematic-tutorial-20261019/regression-complete/report.json').read_text(encoding='utf-8'))
failed_cases = [case for case in visual_report['results'] if case['status'] == 'failed']
report = {'status':'OWNER_VISUAL_REVIEW_PENDING','game_source_modified':False,
          'save_profile':'Isolated APPDATA; preview has no save or quest APIs',
          'movie':str(video),'sha256':sha(video),'duration_seconds':duration,
          'resolution':[432,960],'fps':30,'audio':{'speech':False,'music':False,'sfx':True,
          'peak_dbfs':round(20*np.log10(peak),2),'rms_dbfs':round(20*np.log10(rms),2)},
          'native_preview_checks':99,'layouts':['432x960','360x800','360x640'],
          'functional_checks_passed':7800,
          'legacy_visuals':{'status':'FAILED','failed_count':len(failed_cases),
          'cases':[{'id':case['id'],'metrics':case['metrics'],'threshold_failures':case['threshold_failures']} for case in failed_cases],
          'scope':'Legacy captures do not load the new cinematic. Production source and reference files remain unchanged. Do not claim the complete visual workflow passed.'},
          'protected_source_sha256':source_hashes,'protected_references_sha256':reference_hashes,
          'scope':'Three-shot visual direction preview; full interactive growing-cycle integration awaits approval',
          'limitations':['No Android test or APK','Clean-cache import crashed natively; validation mirror reused the current imported cache'],
          'published':False,'commit_created':False}
(OUTPUT/'review-report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
(PROPOSAL/'review-report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print('CINEMATIC_VIDEO_AND_SFX_VERIFIED=PASSED')
print(json.dumps({k:report[k] for k in ['movie','duration_seconds','resolution','audio']},ensure_ascii=False))
