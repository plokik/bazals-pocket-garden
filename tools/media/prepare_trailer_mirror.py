from pathlib import Path
import hashlib
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
MIRROR = ROOT / 'tmp/trailer-20261019/project'
OUTPUT = Path('C:/Users/drikv/Videos/Bazals Pocket Garden/Trailer 2026-10-19')
OUTPUT.mkdir(parents=True,exist_ok=True)
(OUTPUT/'sources').mkdir(exist_ok=True)
target = MIRROR/'tools/media/record_trailer_20261019.gd'
target.parent.mkdir(parents=True,exist_ok=True)
shutil.copy2(ROOT/'tools/media/record_trailer_20261019.gd',target)
config = (ROOT/'project.godot').read_text(encoding='utf-8')
config = config.replace('window/size/window_width_override=432','window/size/window_width_override=1080')
config = config.replace('window/size/window_height_override=960','window/size/window_height_override=2400')
config += '\n[editor]\nmovie_writer/mjpeg_quality=0.97\n'
(MIRROR/'project.godot').write_text(config,encoding='utf-8')
source_files = ['project.godot','scripts/main.gd','scripts/game_session.gd','scripts/ui/guided_tutorial.gd']
snapshot = {name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in source_files}
(OUTPUT/'source-snapshot.json').write_text(json.dumps(snapshot,indent=2),encoding='utf-8')
print(OUTPUT)
