"""Decode the shipped audio and verify headroom, loop joins and manifest hashes."""
from pathlib import Path
import hashlib
import json
import math
import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[2]


def verify():
    manifest = json.loads((ROOT/'assets/audio/garden_v1/manifest.json').read_text(encoding='utf-8'))
    approved = json.loads((ROOT/'assets/audio/garden_v2/manifest.json').read_text(encoding='utf-8'))
    # Preserve verification of the archived score and all unchanged effects,
    # while checking the newly approved runtime music as well.
    manifest['music'].update(approved['music'])
    rows = []
    for group in ('music', 'sfx', 'ambience'):
        for name, item in manifest[group].items():
            path = ROOT/item['file']
            x, rate = sf.read(path, dtype='float32', always_2d=True)
            peak = float(np.max(np.abs(x)))
            rms = float(np.sqrt(np.mean(x*x)))
            jump = float(np.max(np.abs(x[0]-x[-1])))
            assert rate == 48000 and np.isfinite(x).all(), name
            assert .001 < peak < .97, (name, 'silent or clipped', peak)
            assert abs(len(x)/rate-item['seconds']) < .01, name
            assert hashlib.sha256(path.read_bytes()).hexdigest() == item['sha256'], name
            if group == 'music':
                assert x.shape[1] == 2 and 90 <= len(x)/rate <= 125, name
                assert jump < .025, (name, 'loop boundary discontinuity', jump)
                assert abs(float(np.mean(x))) < .003, (name, 'DC offset')
            rows.append(dict(id=name, group=group, seconds=len(x)/rate, peak=peak,
                             rms_db=20*math.log10(rms), loop_join_jump=jump))
    levels = [row['rms_db'] for row in rows if row['group'] == 'music']
    assert max(levels)-min(levels) < 1.5, 'Music level changes between locations'
    result = dict(passed=True, tracks=len(manifest['music']), active_tracks=list(approved['music']), effects=len(manifest['sfx']),
                  ambiences=len(manifest['ambience']), music_seconds=sum(v['seconds'] for v in manifest['music'].values()),
                  assets=rows)
    output = ROOT/'.godot/approved-delivery-20261028/audio-asset-verification.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(f'AUDIO_ASSET_VERIFICATION=PASSED files={len(rows)}')


if __name__ == '__main__':
    verify()
