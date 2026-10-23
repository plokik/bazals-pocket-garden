"""Reproducible, local FFmpeg edit. Never opens a player save or changes the game.

Native 1080x2400 gameplay is placed pixel-for-pixel inside a 1200x2700 canvas.
CZ/EN promotional captions live entirely outside the gameplay rectangle.
"""
from pathlib import Path
import argparse, csv, hashlib, json, math, os, random, re, shutil, subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
PACKAGED = (HERE/'media_assets').is_dir()
ROOT = HERE/'media_assets' if PACKAGED else Path(__file__).resolve().parents[2]
OUT = HERE.parent if PACKAGED else Path('C:/Users/drikv/Videos/Bazals Pocket Garden/Trailer 2026-10-19')
SRC = OUT/'sources'
EDIT = OUT/'edit_project'
FFMPEG = os.environ.get('BAZAL_FFMPEG') or shutil.which('ffmpeg') or next(Path('C:/Users/drikv/Documents/ChatGPT/How to grow_/output/cinematic-tutorial-20261019/.media-tools/imageio_ffmpeg/binaries').glob('*.exe'))
W,H,FPS = 1200,2700,30
ENC = ['-c:v','h264_nvenc','-preset','p6','-tune','hq','-rc','vbr','-cq','14','-b:v','0','-profile:v','high','-level:v','5.1','-g','30','-bf','2','-pix_fmt','yuv420p','-color_range','tv','-colorspace','bt709','-color_trc','bt709','-color_primaries','bt709']

def run(args, label, binary=False):
    EDIT.mkdir(parents=True, exist_ok=True)
    p = subprocess.run([str(FFMPEG),'-hide_banner','-y',*map(str,args)],cwd=EDIT,capture_output=True)
    (EDIT/(label+'.log')).write_bytes(p.stderr)
    if p.returncode:
        raise RuntimeError(label+'\n'+p.stderr.decode(errors='replace')[-5000:])
    return p.stdout if binary else p.stderr.decode(errors='replace')

def chapter(segment, name):
    data=json.loads((SRC/(segment+'-chapters.json')).read_text(encoding='utf-8'))
    return next(c['seconds'] for c in data['chapters'] if c['id']==name)

def plan():
    rows=[]
    def add(seg, ch, offset, duration, cz, en, detail_cz, detail_en):
        rows.append(dict(segment=seg,chapter=ch,start=round(chapter(seg,ch)+offset,3) if seg else 0,
                         frames=round(duration*FPS),cz=cz,en=en,detail_cz=detail_cz,detail_en=detail_en))
    add(None,'intro',0,2.5,'Vypěstuj si malou radost','Grow a little joy','Malovaný svět, který ožívá','A painted world comes to life')
    add('world','workshop_room',0.3,3,'Tvoje místo pro malá kouzla','Your place for little wonders','Bazalova dílna a tvůj kočičí společník','Bazal’s workshop and your feline companion')
    add('grow','rack',0.3,2.5,'Od semínka k vlastní zahradě','From a seed to your own garden','Různé bylinky. Každá má svůj příběh.','Different herbs. Each with its own story.')
    add('grow','planting',0.0,3,'Začni jediným semínkem','It starts with a single seed','Zasaď svou první bylinku','Plant your first herb')
    add('grow','watering',0.0,2.5,'Dej jí trochu péče','Give it a little care','Zalévání, výživa, světlo a vzduch','Water, nutrients, light and fresh air')
    add('grow','light',0.0,1.5,'Dej jí trochu péče','Give it a little care','Najdi správné podmínky pro růst','Find the right conditions to grow')
    add('grow','measurements',0.3,1.5,'Poznej, co tvoje rostliny potřebují','Learn what your plants need','Sleduj vývoj pěstitelských podmínek','Keep an eye on growing conditions')
    add('world','greenhouse_outside',1.0,3.5,'Za dveřmi čeká další svět','Another world awaits outside','Kouzelná zahrada a poletující motýli','A magical garden with fluttering butterflies')
    add('world','greenhouse_door',0.0,1.8,'Za dveřmi čeká další svět','Another world awaits outside','Vstup do svého skleníku','Step into your greenhouse')
    add('world','greenhouse_inside',0.2,2.5,'Vypěstuj ještě něco navíc','Grow something more','Zelenina a nové možnosti pěstování','Vegetables and new ways to grow')
    add('grow','harvest',0.1,1.5,'Tvoje péče přináší úrodu','Your care bears fruit','Sklízej vlastní bylinky','Harvest your own herbs')
    add('grow','drying',0.1,1.8,'Tvoje péče přináší úrodu','Your care bears fruit','Usušené bylinky najdou další využití','Dry your herbs for something new')
    add('craft','craft_mix',0.0,4.4,'Proměň úrodu v malé poklady','Turn your harvest into little treasures','Míchej recepty v Bazalově dílně','Mix recipes in Bazal’s workshop')
    add('craft','product_lavender',1.2,1.5,'Vytvoř něco vlastního','Make something of your own','Levandulový sáček','A lavender sachet')
    add('craft','product_tea',1.2,1.5,'Vytvoř něco vlastního','Make something of your own','Bylinkový čaj','Herbal tea')
    add('craft','product_gift',1.2,1.5,'Vytvoř něco vlastního','Make something of your own','Dárkový bylinkový balíček','A herbal gift set')
    add('craft','teahouse',1.6,1.8,'Udělej radost i ostatním','Share a little joy','Splň zakázku pro čajovnu','Complete an order for the teahouse')
    add('progress','herbarium',1.5,2.5,'Objevuj, sbírej a uč se','Discover, collect and learn','Tvůj vlastní malovaný herbář','Your very own illustrated herbarium')
    add('progress','journal',0.4,1.8,'S každou úrodou rosteš i ty','Grow with every harvest','Pěstitelský deník a nové dovednosti','A grower’s journal and new skills')
    add('progress','professor',0.4,2,'Profesor Bazal má další nápady','Professor Bazal has more ideas','Příběhové úkoly a malá dobrodružství','Story quests and little adventures')
    add('progress','daily',0.3,1.5,'Každý den něco nového','Something new every day','Denní výzvy','Daily challenges')
    add('progress','orders',0.3,1.5,'Každý den něco nového','Something new every day','Bylinkové zakázky a odměny','Herbal orders and rewards')
    add('progress','shop',0.3,1.3,'Rozšiř svůj malý svět','Make your little world grow','Další semínka a bylinky','More seeds and herbs')
    add('progress','equipment',0.3,1.3,'Rozšiř svůj malý svět','Make your little world grow','Vylepšení pěstitelské výbavy','Upgrade your growing equipment')
    add('progress','levels',0.3,1.3,'Rozšiř svůj malý svět','Make your little world grow','Nové úrovně a odměny','New levels and rewards')
    add('progress','decor',0.3,1.3,'Rozšiř svůj malý svět','Make your little world grow','Dekorace podle tvého vkusu','Decorations to make it yours')
    add('progress','botanical_pack',1.8,1.6,'Rozšiř svůj malý svět','Make your little world grow','Botanické balíčky plné překvapení','Botanical packs full of surprises')
    add('progress','wheel',0.4,4.4,'Zkus své každodenní štěstí','Try your daily luck','Jedno roztočení denně zdarma','One free spin every day')
    add('world','cat_stretch',0.0,2,'A nikdy na to nejsi sám','And you’re never alone','Kočičí společník s vlastními plány','A feline companion with plans of his own')
    add('world','cat_chase',3.2,3.5,'A nikdy na to nejsi sám','And you’re never alone','Kočičí společník s vlastními plány','A feline companion with plans of his own')
    add(None,'outro',0,2.8,'Co vypěstuješ ty?','What will you grow?','Tvá malá zahrada. Velká radost.','Your little garden. A whole lot of joy.')
    t=0
    for i,r in enumerate(rows):
        r.update(index=i, timeline=t/FPS, duration=r['frames']/FPS)
        t+=r['frames']
    return rows

def frame(seg, seconds, name):
    target=EDIT/(name+'.png')
    run(['-ss',seconds,'-i',SRC/(seg+'.avi'),'-frames:v','1','-update','1',target],name)
    return target

def inspect():
    EDIT.mkdir(parents=True,exist_ok=True)
    shots=plan()
    (EDIT/'timeline.json').write_text(json.dumps({'fps':FPS,'canvas':[W,H],'gameplay_rect':[60,150,1080,2400], 'shots':shots},ensure_ascii=False,indent=2),encoding='utf-8')
    thumb_w,thumb_h=240,570
    sheet=Image.new('RGB',(thumb_w*8,thumb_h*4),(16,36,26))
    font=ImageFont.truetype(str(ROOT/'assets/fonts/Poppins-SemiBold.ttf'),13)
    draw=ImageDraw.Draw(sheet)
    for r in shots:
        if not r['segment']: continue
        p=frame(r['segment'],r['start']+min(0.7,r['duration']/2),f"check-{r['index']:02}")
        im=Image.open(p).convert('RGB'); im.thumbnail((234,520))
        i=r['index']; x=(i%8)*thumb_w+3; y=(i//8)*thumb_h
        sheet.paste(im,(x,y+40))
        draw.text((x,y),f"{i:02} · {r['timeline']:.1f}s · {r['chapter']}",font=font,fill='#e8eec6')
    sheet.save(OUT/'shot-review.jpg',quality=94)
    print('CONTACT_SHEET_READY',OUT/'shot-review.jpg',flush=True)

def ass_time(s):
    cent=round(s*100); return f'{cent//360000}:{cent//6000%60:02}:{cent//100%60:02}.{cent%100:02}'

def captions(lang, shots):
    font='Poppins SemiBold'
    text='''[Script Info]\nScriptType: v4.00+\nPlayResX: 1200\nPlayResY: 2700\nWrapStyle: 2\nScaledBorderAndShadow: yes\nYCbCr Matrix: TV.709\n\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n'''
    for name,size,color in [('Header',49,'&H00EBF3DC'),('Footer',32,'&H00CCE1B5'),('Brand',23,'&H0097BEAA'),('Card',65,'&H00EBF3DC'),('CardFoot',34,'&H00CCE1B5')]:
        text+=f'Style: {name},{font},{size},{color},{color},&H00203A22,&H00000000,0,0,0,0,100,100,0,0,1,0,0,5,0,0,0,1\n'
    text+='\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n'
    def event(start,end,style,xy,content,fade=True):
        nonlocal text
        tags=f'{{\\pos({xy[0]},{xy[1]})'+('\\fad(150,120)' if fade else '')+'}'
        text+=f'Dialogue: 0,{ass_time(start)},{ass_time(end)},{style},,0,0,0,,{tags}{content}\n'
    for r in shots:
        start=r['timeline']; end=start+r['duration']
        if r['segment']:
            event(start,end,'Brand',(600,32),'BAZAL’S POCKET GARDEN',False)
            event(start,end,'Header',(600,91),r[lang])
            event(start,end,'Footer',(600,2620),r['detail_'+lang])
        else:
            event(start,end,'Brand',(600,390),'BAZAL’S POCKET GARDEN')
            event(start,end,'Card',(600,535 if r['chapter']=='intro' else 2020),r[lang])
            event(start,end,'CardFoot',(600,2050 if r['chapter']=='intro' else 2130),r['detail_'+lang])
    path=EDIT/f'captions_{lang}.ass'; path.write_text(text,encoding='utf-8-sig')

def artwork():
    # All illustrations are existing approved game art; these cards are editorial.
    EDIT.mkdir(parents=True,exist_ok=True)
    y,x=np.mgrid[0:H,0:W]
    glow=np.exp(-(((x-W/2)/(W*.8))**2+((y-H*.46)/(H*.44))**2))
    rgb=np.zeros((H,W,3),dtype=np.uint8)
    for c,(base,extra) in enumerate([(14,18),(38,41),(29,24)]): rgb[:,:,c]=base+glow*extra
    bg=Image.fromarray(rgb).convert('RGBA')
    d=ImageDraw.Draw(bg)
    d.rounded_rectangle((38,38,W-38,H-38),radius=70,outline=(182,199,124,150),width=2)
    flourish=Image.open(ROOT/'assets/ui/startup/leafy_flourish_user.png').convert('RGBA')
    flourish.thumbnail((840,840),Image.Resampling.LANCZOS)
    # Existing leafy corners; keep the logo silhouette clear.
    bg.alpha_composite(flourish,(-240,-170))
    bg.alpha_composite(flourish.transpose(Image.Transpose.ROTATE_180),(W-600,H-590))
    logo=Image.open(ROOT/'assets/ui/startup/bazals_pocket_garden_logo.png').convert('RGBA')
    logo.thumbnail((1050,1050),Image.Resampling.LANCZOS)
    rng=random.Random(68)
    particles=[(rng.uniform(110,W-110),rng.uniform(550,H-450),rng.uniform(2,5),rng.random()*6.28) for _ in range(27)]
    for kind,dur in [('intro',2.5),('outro',2.8)]:
        path=EDIT/(kind+'.mp4')
        cmd=[str(FFMPEG),'-hide_banner','-y','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgb24','-s',f'{W}x{H}','-r',str(FPS),'-i','pipe:0','-f','lavfi','-i','anullsrc=r=48000:cl=stereo','-frames:v',str(round(dur*FPS)),*ENC,'-c:a','aac','-b:a','320k','-ar','48000','-movflags','+faststart',str(path)]
        with (EDIT/(kind+'-render.log')).open('wb') as log:
            p=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.DEVNULL,stderr=log)
            for index in range(round(dur*FPS)):
                t=index/FPS; image=bg.copy(); draw=ImageDraw.Draw(image)
                for px,py,r,phase in particles:
                    a=int(90+80*math.sin(t*1.8+phase))
                    xx=px+math.sin(t*.7+phase)*16; yy=py-t*17
                    draw.ellipse((xx-r,yy-r,xx+r,yy+r),fill=(216,235,136,a))
                scale=.94+.035*math.sin(min(1,t/dur)*math.pi/2)
                size=(round(logo.width*scale),round(logo.height*scale))
                obj=logo.resize(size,Image.Resampling.LANCZOS)
                image.alpha_composite(obj,((W-size[0])//2,round(800+14*math.cos(t*1.2))))
                if index==round(dur*FPS)//2: image.convert('RGB').save(EDIT/(kind+'-poster.png'))
                p.stdin.write(image.convert('RGB').tobytes())
            p.stdin.close(); code=p.wait()
            if code: raise RuntimeError('Card renderer failed: '+str(path))
    print('EDITORIAL_CARDS_READY',flush=True)

def picture(shots):
    clips=EDIT/'clips'; clips.mkdir(exist_ok=True)
    for r in shots:
        target=clips/f"{r['index']:02}.mp4"
        if target.exists(): continue
        if not r['segment']:
            shutil.copy2(EDIT/(r['chapter']+'.mp4'),target); continue
        vf='scale=in_range=full:out_range=tv:in_color_matrix=bt601:out_color_matrix=bt709,setsar=1,pad=1200:2700:60:150:color=0x163b2f,drawbox=x=56:y=146:w=1088:h=2408:color=0xb6c77c@0.75:t=2'
        # The tiny audio fades prevent edit clicks; the visual gameplay is untouched.
        af=f"afade=t=in:d=0.04,afade=t=out:st={max(0,r['duration']-.05):.3f}:d=0.05"
        run(['-ss',r['start'],'-i',SRC/(r['segment']+'.avi'),'-t',r['duration'],'-vf',vf,'-af',af,'-r',FPS,*ENC,'-c:a','aac','-b:a','320k','-ar','48000','-movflags','+faststart',target],f"clip-{r['index']:02}")
        print('SHOT_RENDERED',r['index'],r['chapter'],flush=True)
    (EDIT/'concat.txt').write_text(''.join(f"file 'clips/{r['index']:02}.mp4'\n" for r in shots),encoding='utf-8')
    run(['-f','concat','-safe','0','-i','concat.txt','-c','copy','-movflags','+faststart','picture_master.mp4'],'picture-master')
    print('PICTURE_MASTER_READY',flush=True)

def sound(duration):
    music=ROOT/'assets/audio/garden_v1/music/bazal_theme.ogg'
    # Original game score and captured real SFX, with a soft ending and no voiceover.
    graph=f'[0:a]volume=0.34,afade=t=in:d=1.3,afade=t=out:st={duration-3}:d=3[m];[1:a]volume=2.5[s];[m][s]amix=inputs=2:duration=longest:normalize=0,atrim=duration={duration}[a]'
    run(['-i',music,'-i','picture_master.mp4','-filter_complex',graph,'-map','[a]','-c:a','pcm_s24le','mix.wav'],'audio-mix')
    log=run(['-i','mix.wav','-af','loudnorm=I=-17:TP=-1.5:LRA=9:print_format=json','-f','null','-'],'audio-measure')
    measured=json.loads(re.search(r'\{\s*"input_i".*?\}',log,re.S).group())
    (EDIT/'loudness-first-pass.json').write_text(json.dumps(measured,indent=2),encoding='utf-8')
    filt='loudnorm=I=-17:TP=-1.5:LRA=9:'+':'.join(f'{k}={measured[v]}' for k,v in [('measured_I','input_i'),('measured_TP','input_tp'),('measured_LRA','input_lra'),('measured_thresh','input_thresh'),('offset','target_offset')])+':linear=true:print_format=json'
    run(['-i','mix.wav','-af',filt,'-ar','48000','-c:a','pcm_s24le','soundtrack.wav'],'audio-normalize')
    print('SOUNDTRACK_READY',flush=True)

def final(shots):
    fonts=EDIT/'fonts'; fonts.mkdir(exist_ok=True)
    for p in (ROOT/'assets/fonts').glob('*.ttf'): shutil.copy2(p,fonts/p.name)
    for lang in ['cz','en']:
        captions(lang,shots)
        name=f'Bazals_Pocket_Garden_trailer_{lang.upper()}.mp4'
        duration=sum(r['frames'] for r in shots)/FPS
        vf=f"setpts=PTS-STARTPTS,fps=30,ass=captions_{lang}.ass:fontsdir=fonts,fade=t=in:d=0.4,fade=t=out:st={duration-.6}:d=0.6"
        run(['-i','picture_master.mp4','-i','soundtrack.wav','-map','0:v:0','-map','1:a:0','-vf',vf,*ENC,'-r',FPS,'-c:a','aac','-b:a','320k','-ar','48000','-t',duration,'-metadata',f'title=Bazal’s Pocket Garden — {lang.upper()} trailer','-movflags','+faststart',OUT/name],f'final-{lang}')
        print('FINAL_READY',OUT/name,flush=True)

def qa(shots):
    result={}
    for lang in ['cz','en']:
        path=OUT/f'Bazals_Pocket_Garden_trailer_{lang.upper()}.mp4'
        log=run(['-i',path,'-map','0:v:0','-map','0:a:0','-f','null','-'],f'decode-{lang}')
        assert '1200x2700' in log and '30 fps' in log
        frames=int(re.findall(r'frame=\s*(\d+)',log)[-1])
        assert frames==sum(r['frames'] for r in shots),frames
        assert not re.search(r'error while decoding|invalid data found|corrupt decoded frame',log,re.I)
        log_audio=run(['-i',path,'-vn','-af','loudnorm=I=-17:TP=-1.5:LRA=9:print_format=json','-f','null','-'],f'final-loudness-{lang}')
        levels=json.loads(re.search(r'\{\s*"input_i".*?\}',log_audio,re.S).group())
        assert float(levels['input_tp'])<=-0.7,levels
        result[lang]={'file':str(path),'bytes':path.stat().st_size,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'full_decode':'passed','decoded_frames':frames,'audio':levels}
        run(['-ss','27.5','-i',path,'-frames:v','1','-update','1',OUT/f'trailer-{lang}-preview.png'],f'poster-{lang}')
    source=json.loads((OUT/'source-snapshot.json').read_text())
    if not PACKAGED:
        result['protected_source_unchanged']={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest()==h for p,h in source.items()}
        assert all(result['protected_source_unchanged'].values())
    else:
        result['protected_source_unchanged']='Not rechecked by media-only package; original capture receipt is source-snapshot.json'
    result['duration_seconds']=sum(r['frames'] for r in shots)/FPS
    result['canvas']=[W,H];result['native_gameplay']=[1080,2400];result['fps']=FPS
    result['gameplay_crop']='none';result['voiceover']='none';result['interface_language']='Czech; promotional captions CZ and EN'
    (OUT/'verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    print('BOTH_TRAILERS_VERIFIED',json.dumps(result,ensure_ascii=False),flush=True)

def deliver(shots):
    (EDIT/'timeline.json').write_text(json.dumps({'fps':FPS,'canvas':[W,H],'gameplay_rect':[60,150,1080,2400],'shots':shots},ensure_ascii=False,indent=2),encoding='utf-8')
    with (EDIT/'shot_list.csv').open('w',newline='',encoding='utf-8-sig') as f:
        writer=csv.DictWriter(f,fieldnames=list(shots[0]));writer.writeheader();writer.writerows(shots)
    def stamp(s):
        ms=round(s*1000);return f'{ms//3600000:02}:{ms//60000%60:02}:{ms//1000%60:02},{ms%1000:03}'
    for lang in ['cz','en']:
        content=''
        for i,r in enumerate(shots):
            content+=f"{i+1}\n{stamp(r['timeline'])} --> {stamp(r['timeline']+r['duration'])}\n{r[lang]}\n{r['detail_'+lang]}\n\n"
        (EDIT/f'captions_{lang}.srt').write_text(content,encoding='utf-8-sig')
    if not PACKAGED:
        assets=['assets/ui/startup/bazals_pocket_garden_logo.png','assets/ui/startup/leafy_flourish_user.png','assets/audio/garden_v1/music/bazal_theme.ogg']
        assets += [str(p.relative_to(ROOT)) for p in (ROOT/'assets/fonts').glob('*') if p.suffix in ['.ttf','.txt']]
        for rel in assets:
            target=EDIT/'media_assets'/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/rel,target)
        shutil.copy2(__file__,EDIT/'render_trailers.py')
        logroot=ROOT/'tmp/trailer-20261019/project/.godot'
        logs=EDIT/'capture_logs';logs.mkdir(exist_ok=True)
        for name in ['trailer-grow.log','trailer-world.log','trailer-craft-v2.log','trailer-progress.log']:
            shutil.copy2(logroot/name,logs/name)
    readme='''BAZAL'S POCKET GARDEN — TRAILER CZ + EN, 19. 10. 2026

HOTOVÁ VIDEA
Bazals_Pocket_Garden_trailer_CZ.mp4
Bazals_Pocket_Garden_trailer_EN.mp4
Obě verze: 67,1 sekundy, 1200 × 2700, 30 fps, H.264 High / AAC stereo 48 kHz.
České nebo anglické jsou propagační popisky. Herní rozhraní zůstává česky.
Bez dabingu. Původní hudba hry a skutečné zaznamenané herní efekty.

OBRAZ
Veškerý herní obraz je nativní 1080 × 2400, bez ořezu a bez zmenšení.
Je vložený na pozici x=60, y=150 do zeleného plátna 1200 × 2700.
Propagační texty jsou mimo herní obraz, žádný ovládací prvek není zakrytý.
Animované logo na začátku a konci je střihová grafika; záběry hry jsou skutečné.
Ukázkový profil zobrazuje různá stadia postupu. Nejde o nepřerušený průchod novou hrou.
Neschválený nový filmový tutorial nebyl přidán ani prezentován jako hotová funkce.

PODKLADY PRO VLASTNÍ STŘIH
sources/grow.avi — sázení, zalévání, světlo, měření, péče, sklizeň, sušení, balení
sources/world.avi — dílna, kocour, zahrada, motýli, dveře, skleník, honička s myší
sources/craft.avi — recepty, hmoždíř, úspěch, tři výrobky, zakázka pro čajovnu
sources/progress.avi — herbář, deník, profesor, denní výzva, zakázky, obchod, výbava,
                       úrovně, dekorace, botanický balíček, kolo štěstí
Celkem přes 2 minuty nezkráceného obrazu 1080 × 2400 / 30 fps se zvukem PCM.
AVI používá kvalitní MJPEG, není bezeztrátové. Původní vysokou kvalitu má zachovanou.

edit_project/picture_master.mp4 — střih bez propagačních textů, se zvuky hry
edit_project/soundtrack.wav — hotový stereo mix hudby a efektů, PCM 24 bit / 48 kHz
edit_project/captions_cz.ass + captions_en.ass — přesně umístěné animované popisky
edit_project/captions_cz.srt + captions_en.srt — prosté editovatelné texty a časování
edit_project/timeline.json + shot_list.csv — úplný seznam záběrů se zdroji a časy
edit_project/clips — jednotlivé sestřižené záběry bez propagačních textů
edit_project/render_trailers.py — opakovatelný střih a export přes FFmpeg
edit_project/media_assets — použité originální logo, ozdoby, hudba a fonty

OBNOVENÍ EXPORTU
Python s numpy a Pillow; FFmpeg s libass a NVIDIA NVENC. Cestu k FFmpeg lze zadat
proměnnou prostředí BAZAL_FFMPEG. Na tomto PC je již dostupný a obě videa jsou hotová.
Texty lze změnit ve funkci plan() souboru render_trailers.py a poté spustit:
python render_trailers.py final
Při změně samotných záběrů znovu vytvoř picture, sound a final.

OVĚŘENÍ
verification.json — dekódování celých videí, snímky, rozměry, zvuk, SHA-256.
Originální hra ani uložený postup se pro natáčení nemění. Nahrávání běželo v úplné
kopii projektu a v oddělených demo profilech. Čisté logy jsou v capture_logs.
Hudební mix má přibližně -17 LUFS a špičky pod -1 dBTP.
'''
    (OUT/'PRO_STRIH.txt').write_text(readme,encoding='utf-8-sig')
    print('EDITABLE_SOURCE_PACKAGE_READY',flush=True)

if __name__=='__main__':
    parser=argparse.ArgumentParser(); parser.add_argument('action',choices=['inspect','artwork','picture','sound','final','qa','deliver','all']); args=parser.parse_args()
    if args.action=='artwork': artwork()
    else:
        shots=plan()
        if args.action in ['inspect','all']: inspect()
        if args.action=='all': artwork()
        if args.action in ['picture','all']: picture(shots)
        if args.action in ['sound','all']: sound(sum(r['frames'] for r in shots)/FPS)
        if args.action in ['final','all']: final(shots)
        if args.action in ['qa','all']: qa(shots)
        if args.action in ['deliver','all']: deliver(shots)
