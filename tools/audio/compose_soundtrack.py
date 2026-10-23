"""Original, reproducible Bazal score and designed foley. No third-party samples.

Run with Python + numpy, scipy, soundfile. Music is composed as 32-bar pieces,
not a repeated six-second oscillator. Physical/modal instruments are rendered
offline; the mobile game only decodes compressed Ogg streams.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
import subprocess
import imageio_ffmpeg

import numpy as np
from scipy.signal import butter, sosfilt, lfilter
import soundfile as sf

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/audio/garden_v1"
REVIEW = ROOT / ".godot/soundtrack-20261017"
SR = 48000
RNG = np.random.default_rng(17062026)
TAU = 2 * np.pi
MANIFEST = {"version": 1, "sample_rate": SR, "provenance": "Original offline composition and procedural sound design; no sampled recordings, vocals or external music.", "music": {}, "sfx": {}, "ambience": {}}


def filtered(x, cutoff, kind="lowpass"):
    return sosfilt(butter(2, cutoff, kind, fs=SR, output="sos"), x).astype(np.float32)


def fade(x, attack=.008, release=.04):
    x = np.array(x, dtype=np.float32, copy=True)
    a, r = min(len(x), int(attack*SR)), min(len(x), int(release*SR))
    if a: x[:a] *= np.linspace(0, 1, a, dtype=np.float32)**2
    if r: x[-r:] *= np.linspace(1, 0, r, dtype=np.float32)**2
    return x


def note(midi, seconds, voice="pluck", strength=1.):
    n = int(seconds*SR)
    t = np.arange(n, dtype=np.float32)/SR
    f = 440*2**((midi-69)/12)
    if voice in ("pluck", "harp", "bass"):
        # Fractional-delay string with body resonances and a soft finger attack.
        delay = max(2, int(SR/f-.5))
        excitation = RNG.normal(0, .6, delay).astype(np.float32)
        excitation = filtered(excitation, min(7500, f*14))
        source = np.zeros(n, np.float32)
        source[:min(delay,n)] = excitation[:n]
        a = np.zeros(delay+2); a[0]=1; a[-2:]=-.498
        x = lfilter([1], a, source).astype(np.float32)
        x += .12*np.sin(TAU*f*t)*np.exp(-t*2)
        x = filtered(x, 2800 if voice == "bass" else 6800)
        x *= np.exp(-t*(1.1 if voice=="harp" else .65))
    elif voice == "wood":
        x = sum(g*np.sin(TAU*f*k*t)*np.exp(-t*d) for k,g,d in [(1,1,2.9),(3.98,.3,6),(9.2,.07,12)])
    elif voice == "bell":
        x = sum(g*np.sin(TAU*f*k*t)*np.exp(-t*d) for k,g,d in [(1,.65,2.5),(2.005,.3,4.3),(2.76,.16,6.2),(5.4,.05,10)])
    elif voice == "flute":
        env = (1-np.exp(-t*20))*np.exp(-t*.32)
        vibrato = .003*np.sin(TAU*4.6*t)*(1-np.exp(-t*3))
        phase = TAU*f*t + TAU*f*np.cumsum(vibrato)/SR
        x = (.75*np.sin(phase)+.13*np.sin(2*phase)+.045*np.sin(3*phase))*env
        x += filtered(RNG.normal(0,.035,n),[1000,4200],"bandpass")*env
    else:  # soft reed/string pad, no abrupt oscillator on/off
        x = sum(g*np.sin(TAU*f*k*t+depth*np.sin(TAU*rate*t)) for k,g,depth,rate in [(1,.52,.24,.63),(2,.16,.31,.81),(3,.07,.14,.56)])
        x *= (1-np.exp(-t*2))*np.exp(-t*.14)
    x = fade(x, .025 if voice=="flute" else .006, min(.35,seconds*.2))
    return x/(max(.4,float(np.max(np.abs(x)))))*strength


def add(buf, x, seconds, gain=1., pan=0., circular=False):
    offset = int(seconds*SR)
    if buf.ndim == 2:
        gains = np.array([math.sqrt((1-pan)/2), math.sqrt((1+pan)/2)],np.float32)*gain
        x = x[:,None]*gains if x.ndim==1 else x*gain
    else: x=x*gain
    if circular:
        offset %= len(buf)
        first = min(len(x),len(buf)-offset)
        buf[offset:offset+first] += x[:first]
        if first<len(x): buf[:len(x)-first] += x[first:]
    elif offset < len(buf):
        start=max(0,-offset); offset=max(0,offset)
        end=min(len(x)-start,len(buf)-offset)
        if end>0: buf[offset:offset+end] += x[start:start+end]


def room(x, looping=False):
    y = x.copy()
    for delay, gain in [(.043,.14),(.097,.11),(.173,.085),(.281,.06),(.419,.035)]:
        n=int(delay*SR)
        wet=np.roll(x[:,::-1] if x.ndim==2 else x,n,axis=0)
        if not looping: wet[:n]=0
        y+=wet*gain
    return y


def save(group, name, x, title, looping=False, **meta):
    folder=OUT/group; folder.mkdir(parents=True,exist_ok=True)
    x=np.asarray(x,dtype=np.float32)
    peak=float(np.max(np.abs(x))); rms=float(np.sqrt(np.mean(x*x)))
    assert .001 < peak < .96, (name,peak)
    path=folder/(name+(".ogg" if group in ("music","ambience") else ".wav"))
    if path.suffix==".ogg":
        # Stream PCM to ffmpeg: avoids a libsndfile/Vorbis native Windows crash
        # on long stereo buffers while retaining the exact same master signal.
        channels = 2 if x.ndim==2 else 1
        subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),"-v","error","-y","-f","f32le","-ar",str(SR),"-ac",str(channels),"-i","pipe:0","-c:a","libvorbis","-q:a","5",str(path)],input=x.tobytes(),check=True)
    else:
        sf.write(path,x,SR,subtype="PCM_16")
    MANIFEST[group][name]={"title":title,"file":path.relative_to(ROOT).as_posix(),"seconds":round(len(x)/SR,4),"stereo":x.ndim==2,"loop":looping,"peak":round(peak,5),"rms_db":round(20*math.log10(rms),2),"sha256":hashlib.sha256(path.read_bytes()).hexdigest(),**meta}
    if group=="music":
        masters=REVIEW/"masters"; masters.mkdir(parents=True,exist_ok=True)
        sf.write(masters/(name+".flac"),x,SR,subtype="PCM_24")
    print(group,name,round(len(x)/SR,2),flush=True)
    return path


# Shared four-note identity: G B D A, expanded into a different arrangement
# for each location. 32 bars: A / B / A variation / quiet closing answer.
CHORDS=[(43,55,59,62),(40,55,59,64),(36,55,60,64),(38,54,57,62),
        (43,55,59,62),(45,57,60,64),(36,55,60,64),(38,54,57,62)]
MELODY=[[(0,79,1),(1.5,83,.5),(2,86,1),(3,81,.65)],
        [(0,83,1.3),(2,79,.8)],[(.5,84,1),(2,83,1),(3,79,.6)],
        [(0,81,1),(1.5,78,.5),(2,74,1.4)],[(0,79,.7),(1,83,.7),(2,86,1.4)],
        [(.5,84,1),(2,83,.8),(3,81,.7)],[(0,79,1.6),(2.5,76,1)],[(0,78,1.2),(2,81,.8),(3,74,.6)]]


def compose(name,title,bpm,lead,accompaniment,energy,section_pan):
    beat=60/bpm; bar=4*beat; duration=32*bar
    x=np.zeros((round(duration*SR),2),np.float32)
    for b in range(32):
        chord=CHORDS[b%8]; phrase=b//8; start=b*bar
        # Low soft string bass, sparse upper texture, hand-played timing.
        add(x,note(chord[0],bar*1.1,"bass",.075),start,pan=-.05,circular=True)
        if b%2==0:
            for j,m in enumerate(chord[1:]):
                add(x,note(m,bar*1.8,"pad",.018*energy),start+j*.025,pan=(j-1)*.35,circular=True)
        pattern=[0,1,2,1,0,2] if phrase%2==0 else [0,2,1,2,0,1]
        for j,c in enumerate(pattern):
            when=start+(j*2/3)*beat+float(RNG.uniform(-.012,.012))
            add(x,note(chord[1+c],beat*2.2,accompaniment,.053*energy*float(RNG.uniform(.83,1))),when,pan=(-.42 if j%2==0 else .4),circular=True)
        # Leave whole bars of breathing room, particularly the journal track.
        if (b%8 not in (1,6) or phrase==1) and not (energy<.8 and b%2):
            for t,m,d in MELODY[b%8]:
                transpose=-12 if lead=="wood" else 0
                if phrase==2 and b%4==0: m+=-2 if m==83 else 0
                if phrase==3 and b%8>=6: continue
                add(x,note(m+transpose,d*beat+.23,lead,.083 if lead=="flute" else .075),start+t*beat,pan=section_pan,circular=True)
        if b%4==0:
            add(x,note(chord[-1]+12,2.2,"bell",.025),start+3.5*beat,pan=.48,circular=True)
        if energy>=1.03:
            for t in (1,3):
                shaker=filtered(RNG.normal(0,.025,int(SR*.11)),[3500,8200],"bandpass")
                add(x,fade(shaker,.008,.08),start+t*beat,pan=.25,circular=True)
    x=room(x,True)
    # Match perceived bed levels across places; retain transient headroom.
    gain=min(.065/float(np.sqrt(np.mean(x*x))), .60/float(np.max(np.abs(x))))
    x*=gain
    return save("music",name,x,title,True,bpm=bpm,bars=32,key="G major / E minor",instruments=f"{lead}, {accompaniment}, plucked bass, soft reeds, glass accents")


def noise(seconds,level=.3,band=(300,9000)):
    return filtered(RNG.normal(0,level,round(seconds*SR)),band,"bandpass")


def chime(notes,spacing=.1,duration=.7,voice="bell",level=.16):
    x=np.zeros(round((duration+spacing*(len(notes)-1))*SR),np.float32)
    for j,m in enumerate(notes): add(x,note(m,duration,voice,level),j*spacing)
    return fade(room(x),.003,.1)


def rustle(seconds=.6):
    x=noise(seconds,.22,(1200,9000)); t=np.arange(len(x))/SR
    return fade(x*(.3+.7*np.sin(t*TAU*9)**4)*np.exp(-t*2.5),.015,.08)


def drop(f=950,seconds=.12):
    t=np.arange(int(seconds*SR))/SR
    return fade(.18*np.sin(TAU*(f*t+f*.045*(1-np.exp(-t*45))))*np.exp(-t*32),.001,.03)


def meow(seconds=.7,yawn=False):
    t=np.arange(int(seconds*SR))/SR
    f=330+230*np.sin(np.pi*t/seconds)**1.1-100*t/seconds
    phase=TAU*np.cumsum(f)/SR
    # Source/filter cartoon cat voice, deliberately soft and not a recording.
    x=sum(np.sin(k*phase)*np.exp(-((k*f-1100)/1100)**2)/k**.7 for k in range(1,14))
    env=np.sin(np.pi*t/seconds)**1.4
    return fade(filtered(x,3500)*env*(.13 if yawn else .17),.04,.08)


def make_sfx():
    sounds={
        "tap":(chime([67],0,.13,"wood",.17),"Jemné dřevěné klepnutí"),
        "confirm":(chime([67,71],.065,.4,"wood",.13),"Potvrzení"),
        "sparkle":(chime([79,83,86],.09,.8,level=.11),"Růst a drobný pokrok"),
        "behavior":(chime([74,79],.09,.5,"harp",.12),"Reakce bylinky"),
        "reward":(chime([79,83,86],.075,.7,level=.15),"Mince a odměna"),
        "fanfare":(chime([67,71,74,79,83],.11,1.3,"harp",.18),"Velký úspěch"),
        "error":(chime([62,59],.11,.25,"wood",.12),"Jemné odmítnutí"),
        "light":(chime([79,86],.07,.85,level=.1),"Rozsvícení lampy"),
        "fertilize":(rustle(.65)+chime([67],0,.65,"wood",.12),"Přisypání výživy"),
        "package":(rustle(.8),"Zabalení bylinek"),
        "herbs":(rustle(.5),"Vložení bylin"),
        "page":(rustle(.32)*.65,"Otočení stránky herbáře"),
        "purchase":(chime([76,79],.09,.55,"bell",.14),"Nákup"),
        "sale":(chime([79,83,86],.07,.8,"bell",.14),"Prodej"),
        "craft_success":(chime([74,79,83,86],.095,1.1,"harp",.17),"Voňavý výrobek je hotový"),
        "delivery":(chime([67,71,74,79,86],.13,1.4,"harp",.17),"Dodávka pro čajovnu"),
        "wheel_win":(chime([71,74,79,83,86],.09,1.25,"bell",.14),"Výhra kola štěstí"),
        "wheel_tick":(chime([83],0,.07,"wood",.17),"Zub kola štěstí"),
        "door_magic":(chime([86,90,93],.075,.65,"bell",.085),"Kouzlo na klice"),
        "modal_open":(chime([67,74],.045,.2,"wood",.075),"Otevření přehledu"),
        "modal_close":(chime([74,67],.04,.18,"wood",.065),"Zavření přehledu"),
        "nav":(chime([74],0,.16,"harp",.11),"Přechod mezi obrazovkami"),
        "cat_meow":(meow(),"Kocourovo pozdravení"),
        "cat_yawn":(meow(.95,True)*.55,"Tiché zívnutí"),
        "research":(chime([74,78,81,86],.13,1.0,"harp",.13),"Dokončený výzkum"),
        "daily_complete":(chime([79,83,86,91],.1,.9,"harp",.14),"Splněná denní výzva"),
    }
    x=np.zeros(int(SR*1.05),np.float32)
    for t in np.arange(.03,.86,.035): add(x,drop(float(RNG.uniform(650,2200))),t,.32)
    x+=fade(noise(1.05,.07,(700,6400)),.1,.25)
    sounds["care"]=(x,"Zálivka – proud a kapky")
    sounds["water"]=(x.copy(),"Zálivka")
    x=fade(noise(.85,.17,(300,4800)),.22,.28)
    sounds["wind"]=(x,"Jemné proudění vzduchu")
    sounds["treatment"]=(rustle(.7)*.7+chime([71],0,.7,"harp",.1),"Ošetření rostliny")
    x=np.zeros(int(SR*.7),np.float32)
    for t,g in [(.03,1),(.26,.55),(.42,.3)]: add(x,note(49,.16,"wood",.16),t,g)
    add(x,rustle(.4),.21,.45)
    sounds["seed"]=(x,"Semínko dopadne do hlíny")
    sounds["harvest"]=(np.concatenate([rustle(.28),chime([74,79],.07,.35,"harp",.12)]),"Ustřižení a sklizeň")
    sounds["drying"]=(rustle(.45)+chime([62],0,.45,"wood",.13),"Uložení do sušárny")
    x=chime([55,67],.04,.28,"wood",.14)
    sounds["door_handle"]=(x,"Stažení kovové kliky")
    sounds["door_enter"]=(fade(noise(.38,.09,(180,2200)),.08,.18),"Tichý vstup do skleníku")
    x=np.zeros(int(SR*1.2),np.float32)
    for j in range(4):
        add(x,rustle(.22),j*.28,.7)
        add(x,note(47+j%2,.13,"wood",.12),j*.28)
    sounds["grind"]=(x,"Kroužení tloučku v hmoždíři")
    x=np.zeros(int(SR*.85),np.float32)
    for t in np.arange(.02,.7,.09): add(x,drop(float(RNG.uniform(900,1700))),t,.6)
    sounds["tea_pour"]=(x,"Nalévání čaje")
    sounds["gift_wrap"]=(np.concatenate([rustle(.4),np.zeros(4800),rustle(.32)*.6]),"Stuha a dárkový papír")
    t=np.arange(int(SR*1.8))/SR
    x=filtered(RNG.normal(0,.12,len(t)),[70,700],"bandpass")*(.2+.8*np.sin(TAU*24*t)**4)
    sounds["cat_purr"]=(fade(x,.15,.35),"Předení při pohlazení")
    x=np.zeros(int(SR*.8),np.float32)
    for t in (.03,.19,.35,.51,.67): add(x,drop(1700,.07),t,.35)
    sounds["cat_drink"]=(x,"Kocour pije vodu")
    x=np.zeros(int(SR*.5),np.float32)
    for t in (.02,.17,.31,.44): add(x,note(44,.055,"wood",.055),t)
    sounds["cat_steps"]=(x,"Měkké tlapky")
    x=np.zeros(int(SR*.23),np.float32)
    for t in (.02,.12): add(x,drop(3200,.07),t,.16)
    sounds["mouse"]=(x,"Myší písknutí")
    sounds["cat_chase"]=(fade(noise(.6,.12,(250,3600)),.04,.35),"Kocour vyrazí za myší")
    sounds["plant_clear"]=(rustle(.55)*.7,"Vyprázdnění květináče")
    sounds["pot_place"]=(chime([43,55],.025,.25,"wood",.14),"Položení keramického květináče")
    for name,(x,title) in sounds.items():
        x=fade(x,.003,.025)
        save("sfx",name,x,title)
    # Alternate water and tap samples, selected cyclically without repetition.
    save("sfx","tap_alt",chime([69],0,.12,"wood",.14),"Alternativní klepnutí")
    save("sfx","water_alt",fade(np.roll(sounds["care"][0],int(.12*SR)),.08,.2)*.9,"Alternativní zálivka")


def ambience(name,title,outside=False):
    duration=24.; n=int(SR*duration); t=np.arange(n)/SR
    x=np.zeros((n,2),np.float32)
    for side in range(2):
        breeze=filtered(RNG.normal(0,1,n),[180,2400 if outside else 1300],"bandpass")
        x[:,side]=breeze*.012*(.6+.4*np.sin(TAU*t/duration+side)**2)
    if outside:
        for start in (2.5,8.3,16.,21.):
            for j in range(3):
                tt=np.arange(int(.12*SR))/SR
                bird=np.sin(TAU*(2200*tt+380*tt*tt))*np.sin(np.pi*tt/.12)**2*.023
                add(x,bird,start+j*.17,pan=-.6 if start<12 else .65,circular=True)
    # True circular smoothing at the join; no long silent fade at every loop.
    edge=int(.3*SR); bridge=(x[:edge]+x[-edge:])*.5
    x[:edge]=bridge; x[-edge:]=bridge
    x[0]=x[-1]=(x[0]+x[-1])*.5
    save("ambience",name,x,title,True)


def deliver():
    (OUT/"manifest.json").write_text(json.dumps(MANIFEST,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    source=['extends RefCounted','## Generated original audio resource catalog.']
    for section,key in [('music','MUSIC'),('sfx','CUES'),('ambience','AMBIENCE')]:
        source.append('const '+key+' := {')
        for name,d in MANIFEST[section].items(): source.append('\t"'+name+'": preload("res://'+d['file']+'"),')
        source.append('}')
    (ROOT/'scripts/audio_library.gd').write_text('\n'.join(source)+'\n',encoding='utf-8')
    REVIEW.mkdir(parents=True,exist_ok=True)
    excerpts=[]
    for name in MANIFEST["music"]:
        x,_=sf.read(OUT/"music"/(name+".ogg"),dtype="float32",always_2d=True)
        part=x[int(SR*6):int(SR*23)]
        part[:SR]*=np.linspace(0,1,SR)[:,None]; part[-SR:]*=np.linspace(1,0,SR)[:,None]
        excerpts.extend([part,np.zeros((SR,2),np.float32)])
    if excerpts:
        preview=np.concatenate(excerpts)
        subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),"-v","error","-y","-f","f32le","-ar",str(SR),"-ac","2","-i","pipe:0","-c:a","libvorbis","-q:a","5",str(REVIEW/"soundtrack-preview.ogg")],input=preview.tobytes(),check=True)
    fx=[]
    showcase=["tap","seed","water","light","wind","harvest","drying","package","grind","craft_success","tea_pour","gift_wrap","sale","delivery","door_handle","door_magic","wheel_tick","wheel_win","cat_meow","cat_purr","cat_yawn","cat_drink","cat_chase"]
    for name in showcase:
        x,_=sf.read(OUT/"sfx"/(name+".wav"),dtype="float32")
        fx.extend([x,np.zeros(int(.4*SR),np.float32)])
    sf.write(REVIEW/"effects-preview.wav",np.concatenate(fx),SR,subtype="PCM_16")
    (REVIEW/"effects-order.json").write_text(json.dumps(showcase,indent=2),encoding="utf-8")
    with zipfile.ZipFile(REVIEW/"Bazals-Pocket-Garden-audio-v1.zip","w",zipfile.ZIP_DEFLATED,compresslevel=3) as z:
        for p in OUT.rglob("*"):
            if p.is_file() and p.suffix!=".import": z.write(p,p.relative_to(OUT))
        for p in (REVIEW/"masters").glob("*.flac"): z.write(p,"masters/"+p.name)
        z.write(Path(__file__),"source/compose_soundtrack.py")
    print("ORIGINAL_SOUNDTRACK_RENDER=PASSED",flush=True)


if __name__=="__main__":
    parser=argparse.ArgumentParser(); parser.add_argument("--sfx-only",action="store_true"); args=parser.parse_args()
    OUT.mkdir(parents=True,exist_ok=True)
    if args.sfx_only:
        previous=json.loads((OUT/'manifest.json').read_text(encoding='utf-8'))
        MANIFEST['music']=previous['music']
    if not args.sfx_only:
        for spec in [
            ("bazal_theme","Bazalova malá dobrodružství",80,"flute","harp",1.,-.12),
            ("workshop","Voňavá dílna",76,"wood","pluck",1.04,.08),
            ("growing","Trpělivost lístků",72,"flute","harp",.78,-.18),
            ("outside","Za dveřmi skleníku",68,"flute","wood",.88,.12),
            ("market","U zeleného lístku",84,"wood","pluck",1.08,-.08),
            ("journal","Stránky bylinkového deníku",64,"harp","wood",.7,.04),
        ]: compose(*spec)
    make_sfx()
    ambience("garden_air","Zahradní vánek a vzdálení ptáci",True)
    ambience("greenhouse_air","Tiché listí uvnitř skleníku")
    deliver()
