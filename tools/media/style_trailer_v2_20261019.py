"""Second editorial treatment: native full-screen footage, kinetic display type,
painted leaf transitions and restrained gold particles. Does not run the game.
"""
from pathlib import Path
import argparse, hashlib, json, math, random, re, shutil, subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT=Path(__file__).resolve().parents[2]
BASE=Path('C:/Users/drikv/Videos/Bazals Pocket Garden/Trailer 2026-10-19')
OUT=BASE/'V2'
EDIT=OUT/'edit_project'
FF=next(Path('C:/Users/drikv/Documents/ChatGPT/How to grow_/output/cinematic-tutorial-20261019/.media-tools/imageio_ffmpeg/binaries').glob('*.exe'))
W,H,FPS,N=1080,2400,30,2013
DURATION=N/FPS
ENC=['-c:v','h264_nvenc','-preset','p6','-tune','hq','-rc','vbr','-cq','14','-b:v','0','-profile:v','high','-level:v','5.1','-g','30','-bf','2','-pix_fmt','yuv420p','-color_range','tv','-colorspace','bt709','-color_trc','bt709','-color_primaries','bt709']
CREAM='&H00E7F6FF'
GOLD='&H0079D8FF'
FOREST='&H001C2E13'

def run(args,label,binary=False):
    EDIT.mkdir(parents=True,exist_ok=True)
    p=subprocess.run([str(FF),'-hide_banner','-y',*map(str,args)],cwd=EDIT,capture_output=True)
    (EDIT/(label+'.log')).write_bytes(p.stderr)
    if p.returncode: raise RuntimeError(label+'\n'+p.stderr.decode(errors='replace')[-5000:])
    return p.stdout if binary else p.stderr.decode(errors='replace')

def cues():
    # Positions are scene-specific. The main action is left visible.
    rows=[
        (0.10,2.42,300,['VYPĚSTUJ SI','MALOU RADOST'],['GROW A LITTLE','HAPPINESS'],'intro'),
        (2.78,5.20,410,['TVOJE MÍSTO','PRO MALÁ KOUZLA'],['YOUR PLACE FOR','LITTLE WONDERS'],'room'),
        (8.12,10.67,1870,['ZASAĎ.'],['PLANT.'],'plant'),
        (11.16,13.18,1870,['ZALIJ.'],['WATER.'],'water'),
        (13.62,14.94,1870,['NECH RŮST.'],['LET IT GROW.'],'light'),
        (16.99,19.70,560,['ZA DVEŘMI','ČEKÁ DALŠÍ SVĚT'],['A WHOLE NEW','WORLD AWAITS'],'outside'),
        (22.03,24.10,550,['VYPĚSTUJ','JEŠTĚ VÍC'],['GROW','SOMETHING MORE'],'greenhouse'),
        (24.48,25.67,380,['SKLÍZEJ.'],['HARVEST.'],'harvest'),
        (25.98,27.25,380,['USUŠ.'],['DRY.'],'drying'),
        (28.13,31.80,2020,['PROMĚŇ ÚRODU','V MALÉ POKLADY'],['YOUR HARVEST','BECOMES TREASURE'],'craft'),
        (32.14,33.36,1670,['VŮNĚ.'],['SCENT.'],'lavender'),
        (33.64,34.86,1670,['CHUŤ.'],['FLAVOUR.'],'tea'),
        (35.14,36.36,1670,['RADOST.'],['JOY.'],'gift'),
        (36.77,38.12,1670,['POTĚŠ OSTATNÍ.'],['SHARE THE JOY.'],'teahouse'),
        (38.80,40.63,1950,['OBJEVUJ.'],['DISCOVER.'],'herbarium'),
        (40.98,44.28,1970,['S KAŽDOU ÚRODOU','ROSTEŠ I TY'],['GROW WITH','EVERY HARVEST'],'journal'),
        (44.87,47.20,1950,['KAŽDÝ DEN','NOVÁ VÝZVA'],['EVERY DAY','A NEW CHALLENGE'],'daily'),
        (47.65,51.29,1970,['ROZŠIŘUJ','SVŮJ MALÝ SVĚT'],['MAKE YOUR','LITTLE WORLD GROW'],'shop'),
        (51.78,54.07,1970,['PO SVÉM.'],['MAKE IT YOURS.'],'decor'),
        (54.78,58.39,1850,['ROZTOČ TO!'],['GIVE IT A SPIN!'],'wheel'),
        (59.23,63.91,560,['A NIKDY NA TO','NEJSI SÁM'],['AND YOU’RE','NEVER ALONE'],'cat'),
        (64.46,66.95,300,['CO VYPĚSTUJEŠ','TY?'],['WHAT WILL','YOU GROW?'],'outro'),
    ]
    return [dict(start=a,end=b,y=y,cz=cz,en=en,id=id) for a,b,y,cz,en,id in rows]

def stamp(s):
    c=round(s*100);return f'{c//360000}:{c//6000%60:02}:{c//100%60:02}.{c%100:02}'

def fit(text,size):
    fontpath=EDIT/'fonts/Bungee-Regular.ttf'
    while ImageFont.truetype(str(fontpath),size).getlength(text)+max(0,len(text)-1)*1.0>850: size-=1
    assert size>=59,(text,size)
    return size

def captions():
    font=ImageFont.truetype(str(EDIT/'fonts/Bungee-Regular.ttf'),80)
    missing_glyph=font.getmask(chr(0x10ffff))
    missing_signature=(missing_glyph.size,bytes(missing_glyph))
    required=''.join(''.join(c[l]) for c in cues() for l in ['cz','en'])
    missing={c for c in required if not c.isspace() and (font.getmask(c).size,bytes(font.getmask(c)))==missing_signature}
    assert not missing,missing
    # Bungee has unusually tall font metrics. Calibrate libass's visible type
    # size against a real rendered sample instead of trusting nominal points.
    calibration=json.loads((EDIT/'font-calibration.json').read_text())['factor']
    report=[]
    for lang in ['cz','en']:
        text='''[Script Info]\nScriptType: v4.00+\nPlayResX: 1080\nPlayResY: 2400\nWrapStyle: 2\nScaledBorderAndShadow: yes\nYCbCr Matrix: TV.709\n\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n'''
        text+=f'Style: Hero,Bungee,120,{CREAM},{GOLD},{FOREST},&H00000000,0,0,0,0,100,100,1,0,1,5,0,5,0,0,0,1\n'
        text+='Style: Small,Poppins SemiBold,44,&H00E7F6FF,&H00E7F6FF,&H00203918,&H00000000,0,0,0,0,100,100,2,0,1,2,1,5,0,0,0,1\n'
        text+='\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n'
        def event(start,end,style,tags,content,layer=1):
            nonlocal text
            text+=f'Dialogue: {layer},{stamp(start)},{stamp(end)},{style},,0,0,0,,{{{tags}}}{content}\n'
        for c in cues():
            lines=c[lang]
            for i,line in enumerate(lines):
                size=fit(line,154 if len(lines)==1 else (84 if i==0 else 133))
                y=c['y']+(123 if len(lines)==1 else (49 if i==0 else 157))
                start=c['start']+i*.09;end=c['end']
                color=GOLD if i==len(lines)-1 else CREAM
                small=round(93*calibration,2);over=round(103*calibration,2);rest=round(100*calibration,2)
                motion=f'\\fscx{small}\\fscy{small}\\t(0,210,\\fscx{over}\\fscy{over})\\t(210,350,\\fscx{rest}\\fscy{rest})\\fad(80,160)'
                event(start,end,'Hero',f'\\fs{size}\\move(540,{y+14},540,{y+7},0,250)'+motion+'\\1c&H001B2D12&\\3c&H001B2D12&\\bord8\\blur2\\alpha&H20&',line,0)
                event(start,end,'Hero',f'\\fs{size}\\move(540,{y+7},540,{y},0,250)'+motion+f'\\1c{color}&\\bord4.5',line,1)
                report.append(dict(lang=lang,cue=c['id'],line=line,size=size,y=y,width=round(ImageFont.truetype(str(EDIT/'fonts/Bungee-Regular.ttf'),size).getlength(line),1)))
            # A short gold underline completes the entrance; never crosses a main actor.
            if len(lines)==2:
                y=c['y']+225
                event(c['start']+.2,c['end'],'Hero',f'\\an5\\pos(540,{y})\\p1\\bord0\\shad0\\1c{GOLD}&\\fscx0\\t(0,280,\\fscx100)\\fad(80,160)','m 0 0 l 260 0 l 260 3 l 0 3',0)
        # End/intro copy is on the artwork itself, not on an external strip.
        for start,end,y,cz,en in [(0.6,2.4,1890,'MALOVANÝ SVĚT, KTERÝ OŽÍVÁ','A PAINTED WORLD COMES TO LIFE'),(64.8,66.95,1900,'TVÁ MALÁ ZAHRADA. VELKÁ RADOST.','YOUR LITTLE GARDEN. A WHOLE LOT OF JOY.'),(55.1,58.4,2070,'JEDNOU DENNĚ ZDARMA','ONE FREE SPIN EVERY DAY')]:
            event(start,end,'Small',f'\\pos(540,{y})\\fad(180,150)',cz if lang=='cz' else en)
        (EDIT/f'kinetic_{lang}.ass').write_text(text,encoding='utf-8-sig')
    (EDIT/'typography-measurements.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    (EDIT/'cues.json').write_text(json.dumps(cues(),ensure_ascii=False,indent=2),encoding='utf-8')
    print('KINETIC_TYPE_READY; CZECH_GLYPHS_VERIFIED',flush=True)

def ease(v): return max(0,min(1,v))**2*(3-2*max(0,min(1,v)))

def effects():
    # Half-resolution soft FX; all footage and typography stay native 1080x2400.
    fw,fh=W//2,H//2
    leaf=Image.open(ROOT/'assets/ui/detail_painted_v2/runtime/leaf.png').convert('RGBA')
    leaf.thumbnail((550,550))
    yy,xx=np.mgrid[0:220,0:fw]
    alpha=(106*np.cos(np.clip((yy-110)/110,-1,1)*math.pi/2)**2*np.exp(-((xx-fw/2)/(fw*.72))**4)).astype(np.uint8)
    mask=Image.fromarray(alpha)
    gradient=Image.new('RGBA',(fw,220),(8,31,24,0));gradient.putalpha(mask)
    sy,sx=np.mgrid[-16:17,-16:17]
    ga=(160*np.exp(-(sx*sx+sy*sy)/17)).astype(np.uint8)
    spark=Image.new('RGBA',(33,33),(255,219,126,0));spark.putalpha(Image.fromarray(ga))
    rng=random.Random(20261019)
    dust=[(rng.random(),rng.random(),rng.random()*6.28,rng.uniform(.6,1.2)) for _ in range(17)]
    cuts=[16.5,27.6,38.3,58.8]
    cmd=[str(FF),'-hide_banner','-y','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgba','-s',f'{fw}x{fh}','-r',str(FPS),'-i','pipe:0','-an','-c:v','qtrle','-pix_fmt','argb',str(EDIT/'editorial_fx.mov')]
    with (EDIT/'effects-render.log').open('wb') as log:
        p=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.DEVNULL,stderr=log)
        for index in range(N):
            t=index/FPS;im=Image.new('RGBA',(fw,fh),(0,0,0,0))
            active=[c for c in cues() if c['start']<=t<c['end']]
            for c in active:
                op=ease((t-c['start'])/.18)*ease((c['end']-t)/.19)
                if c['id'] not in ['intro','outro']:
                    patch=gradient.copy();patch.putalpha(mask.point([round(i*op) for i in range(256)]))
                    im.alpha_composite(patch,(0,round((c['y']+115)/2-110)))
                for u,v,ph,sc in dust:
                    x=70+u*400+9*math.sin(t*.8+ph);y=(c['y']+95)/2+(v-.5)*122-((t-c['start'])*12)%40
                    if 135<x<405 and abs(y-(c['y']+95)/2)<38: continue
                    glow=spark.copy();glow.putalpha(spark.getchannel('A').point([round(i*op*(.35+.2*math.sin(t*2+ph))) for i in range(256)]))
                    im.alpha_composite(glow,(round(x-16),round(y-16)))
                    r=.8*sc
                    ImageDraw.Draw(im).ellipse((x-r,y-r,x+r,y+r),fill=(255,225,159,round(170*op)))
            # A small flourish around the actual successful mortar animation.
            age=t-30.02
            if 0<=age<1.35:
                for i in range(22):
                    angle=i*2.39996
                    x=270+math.cos(angle)*(15+age*110)
                    y=510+math.sin(angle)*(10+age*65)-age*40
                    opacity=math.sin(min(1,age/1.35)*math.pi)*.58
                    glow=spark.copy();glow.putalpha(spark.getchannel('A').point([round(a*opacity) for a in range(256)]))
                    im.alpha_composite(glow,(round(x-16),round(y-16)))
            for cut in cuts:
                phase=(t-(cut-.37))/.74
                if not 0<=phase<=1: continue
                # Four staggered painted leaves cover the join. Motion blur comes
                # from three nearby exposures instead of stretching the artwork.
                for i in range(4):
                    for exposure,opacity in [(-.016,.12),(-.008,.20),(0,1.0)]:
                        q=phase+exposure-i*.018
                        x=(-760+2650*q)/2
                        y=(230+i*650+120*math.sin(q*math.pi))/2
                        width=round((1080+i%2*90)/2)
                        obj=leaf.resize((width,round(width*leaf.height/leaf.width)),Image.Resampling.BICUBIC)
                        obj=obj.rotate(-44+q*56+i*6,resample=Image.Resampling.BICUBIC,expand=True)
                        if opacity<1: obj.putalpha(obj.getchannel('A').point([round(a*opacity) for a in range(256)]))
                        im.alpha_composite(obj,(round(x-obj.width/2),round(y-obj.height/2)))
            p.stdin.write(im.tobytes())
            if index%300==0: print('FX_FRAMES',index,'/',N,flush=True)
        p.stdin.close();code=p.wait()
        if code: raise RuntimeError('Effects render failed')
    print('PAINTED_TRANSITIONS_READY',flush=True)

def audio():
    # Reuse the original game score and genuine captured game sounds. Add only
    # editorial leaf swishes and a soft final brand accent; still no voiceover.
    sfx=ROOT/'assets/audio/garden_v1/sfx'
    inputs=['-i',BASE/'edit_project/mix.wav']
    graph=[];labels=['[0:a]']
    events=[(16.13,'wind.wav',.32,1.4),(27.23,'wind.wav',.30,1.4),(37.93,'wind.wav',.30,1.4),(58.43,'wind.wav',.28,1.4),(64.4,'sparkle.wav',.22,1.0),(0.14,'sparkle.wav',.12,1.0)]
    for i,(when,name,volume,speed) in enumerate(events,1):
        inputs += ['-i',sfx/name]
        graph.append(f'[{i}:a]asetrate={round(48000*speed)},aresample=48000,volume={volume},adelay={round(when*1000)}|{round(when*1000)}[s{i}]')
        labels.append(f'[s{i}]')
    graph.append(''.join(labels)+f'amix=inputs={len(labels)}:duration=first:normalize=0,atrim=duration={DURATION}[a]')
    run([*inputs,'-filter_complex',';'.join(graph),'-map','[a]','-c:a','pcm_s24le','mix_v2.wav'],'mix-v2')
    log=run(['-i','mix_v2.wav','-af','loudnorm=I=-16.5:TP=-1.5:LRA=9:print_format=json','-f','null','-'],'audio-analysis')
    data=json.loads(re.search(r'\{\s*"input_i".*?\}',log,re.S).group())
    filt='loudnorm=I=-16.5:TP=-1.5:LRA=9:'+':'.join(f'{k}={data[v]}' for k,v in [('measured_I','input_i'),('measured_TP','input_tp'),('measured_LRA','input_lra'),('measured_thresh','input_thresh'),('offset','target_offset')])+':linear=true'
    run(['-i','mix_v2.wav','-af',filt,'-ar','48000','-c:a','pcm_s24le','soundtrack_v2.wav'],'normalize-v2')
    print('TRAILER_SOUND_DESIGN_READY',flush=True)

def graph(lang):
    return f'[0:v]setpts=PTS-STARTPTS,fps=30,crop=1080:2400:60:150[game];[1:v]setpts=PTS-STARTPTS,scale=1080:2400:flags=lanczos,format=rgba[fx];[game][fx]overlay=format=auto:eof_action=pass,ass=kinetic_{lang}.ass:fontsdir=fonts,format=yuv420p,fade=t=in:d=0.25,fade=t=out:st={DURATION-.5}:d=0.5[v]'

def render():
    for lang in ['cz','en']:
        target=OUT/f'Bazals_Pocket_Garden_trailer_{lang.upper()}_V2.mp4'
        run(['-i',BASE/'edit_project/picture_master.mp4','-i','editorial_fx.mov','-i','soundtrack_v2.wav','-filter_complex',graph(lang),'-map','[v]','-map','2:a:0',*ENC,'-r',FPS,'-c:a','aac','-b:a','320k','-ar','48000','-t',DURATION,'-metadata',f'title=Bazal’s Pocket Garden — cinematic trailer {lang.upper()} V2','-movflags','+faststart',target],f'export-{lang}')
        print('V2_EXPORT_READY',target,flush=True)

def previews():
    # Preview the actual composed timeline, including effects and the exact fonts.
    for lang,times in [('cz',[1.2,3.7,8.9,17.8,29.7,39.6,55.7,61.4,65.5]),('en',[8.9,17.8,29.7])]:
        for i,t in enumerate(times):
            run(['-ss',t,'-i',OUT/f'Bazals_Pocket_Garden_trailer_{lang.upper()}_V2.mp4','-frames:v','1','-update','1',EDIT/f'preview-{lang}-{i:02}.png'],f'preview-{lang}-{i:02}')
    thumbs=Image.new('RGB',(1800,1470),'#102e25')
    draw=ImageDraw.Draw(thumbs)
    for i in range(9):
        p=EDIT/f'preview-cz-{i:02}.png';im=Image.open(p).convert('RGB');im.thumbnail((296,658))
        x=(i%6)*300+2;y=(i//6)*735+25
        thumbs.paste(im,(x,y));draw.text((x,y-18),str(i+1),fill='white')
    thumbs.save(OUT/'V2-prehled.jpg',quality=95)
    print('COMPOSED_PREVIEWS_READY',flush=True)

def qa():
    result={'duration_seconds':DURATION,'fps':FPS,'resolution':[W,H],'gameplay_crop':'Only the old external 60px/150px editorial margins removed; native 1080x2400 gameplay retained in full.','captions':'Animated Bungee directly over the scene, with verified Czech glyphs and scene-specific positions.','effects':'Four painted leaf sweeps; gentle gold particles; layered kinetic type; editorial sound accents.','files':{}}
    for lang in ['cz','en']:
        p=OUT/f'Bazals_Pocket_Garden_trailer_{lang.upper()}_V2.mp4'
        log=run(['-i',p,'-map','0:v:0','-map','0:a:0','-f','null','-'],f'decode-{lang}')
        frames=int(re.findall(r'frame=\s*(\d+)',log)[-1])
        assert frames==N and '1080x2400' in log and '30 fps' in log
        assert not re.search(r'error while decoding|invalid data found|corrupt decoded frame',log,re.I)
        levels=run(['-i',p,'-vn','-af','loudnorm=I=-16.5:TP=-1.5:LRA=9:print_format=json','-f','null','-'],f'levels-{lang}')
        data=json.loads(re.search(r'\{\s*"input_i".*?\}',levels,re.S).group())
        assert float(data['input_tp']) < -.8
        result['files'][lang]={'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size,'full_decode':'passed','frames':frames,'audio':data}
    original=json.loads((BASE/'source-snapshot.json').read_text())
    result['protected_game_source_unchanged']={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest()==h for p,h in original.items()}
    assert all(result['protected_game_source_unchanged'].values())
    (OUT/'verification_v2.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    (OUT/'O_VERZI_V2.txt').write_text('''BAZAL’S POCKET GARDEN — TRAILER V2, CZ + EN
67,1 sekundy • 1080 × 2400 • 30 fps • H.264 High • AAC stereo 48 kHz

Velké animované titulky jsou přímo v obraze. Písmo Bungee, krémová a zlatá,
tmavý zelený obrys a prostorový stín. Poloha titulků se mění podle hlavního děje.
Přidané střihové efekty: čtyři průlety malovaných listů, jemné zlaté částice,
nástupy textů s lehkým přesahem a nové zvukové akcenty přechodů.
Herní rozhraní je česky v obou verzích; propagační text je CZ nebo EN.
Herní obraz je celý v nativních 1080 × 2400, byly odstraněny jen vnější pruhy V1.
Původní V1 zůstává zachovaná v nadřazené složce. Hra ani uložený postup se nemění.

edit_project obsahuje texty ASS, cues.json, měření sazby, efekty s průhledností
v editorial_fx.mov, zvukovou stopu soundtrack_v2.wav, logy a vizuální náhledy.
Použity původní záběry a originální grafika hry. Bez dabingu.
Písmo: Bungee, David Jonathan Ross, Google Fonts, SIL OFL 1.1.
https://github.com/google/fonts/tree/main/ofl/bungee
Licence je přiložena ve fonts/OFL-Bungee.txt.
''',encoding='utf-8-sig')
    shutil.copy2(__file__,EDIT/Path(__file__).name)
    print('V2_CZ_AND_EN_VERIFIED',flush=True)

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('action',choices=['captions','effects','audio','render','previews','qa','all']);args=parser.parse_args()
    EDIT.mkdir(parents=True,exist_ok=True)
    if args.action in ['captions','all']: captions()
    if args.action in ['effects','all']: effects()
    if args.action in ['audio','all']: audio()
    if args.action in ['render','all']: render()
    if args.action in ['previews','all']: previews()
    if args.action in ['qa','all']: qa()
