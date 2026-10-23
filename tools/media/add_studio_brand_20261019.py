"""Add the official TK Games website logo without changing approved V2 footage.
Original logo colours, transparency, aspect ratio and the source downloads stay intact.
"""
from pathlib import Path
import importlib.util, hashlib, json, math, re, shutil, subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[2]
BASE=Path('C:/Users/drikv/Videos/Bazals Pocket Garden/Trailer 2026-10-19')
V2=BASE/'V2'
OUT=BASE/'V3-TK-GAMES'
EDIT=OUT/'edit_project'
LOGO=EDIT/'tk-games-header-transparent-1254-20261013.png'
spec=importlib.util.spec_from_file_location('approved_v2',ROOT/'tools/media/style_trailer_v2_20261019.py')
v2=importlib.util.module_from_spec(spec);spec.loader.exec_module(v2)
W,H,FPS=1080,2400,30
PREFIX=1.8
FRAMES=2013+round(PREFIX*FPS)
DURATION=FRAMES/FPS
ENC=v2.ENC.copy();ENC[ENC.index('-cq')+1]='13'

def run(args,label):
    p=subprocess.run([str(v2.FF),'-hide_banner','-y',*map(str,args)],cwd=EDIT,capture_output=True)
    (EDIT/(label+'.log')).write_bytes(p.stderr)
    if p.returncode: raise RuntimeError(label+'\n'+p.stderr.decode(errors='replace')[-4500:])
    return p.stderr.decode(errors='replace')

def prepare():
    (EDIT/'fonts').mkdir(exist_ok=True)
    (EDIT/'licenses').mkdir(exist_ok=True)
    for p in (V2/'edit_project/fonts').glob('*.ttf'):shutil.copy2(p,EDIT/'fonts'/p.name)
    for p in (V2/'edit_project/fonts').glob('*.txt'):shutil.copy2(p,EDIT/'licenses'/p.name)
    for lang in ['cz','en']:
        shutil.copy2(V2/'edit_project'/f'kinetic_{lang}.ass',EDIT/f'kinetic_{lang}.ass')
    image=Image.open(LOGO).convert('RGBA')
    assert image.size==(1254,1254) and image.getchannel('A').getextrema()==(0,255)

def smooth(x):
    x=max(0,min(1,x));return x*x*(3-2*x)

def tracking(draw,text,y,font,fill,spacing=4):
    width=sum(font.getlength(c) for c in text)+spacing*(len(text)-1)
    x=(W-width)/2
    # Keep accented letters and punctuation on one baseline when tracking.
    cap=font.getbbox('H',anchor='ls')
    baseline=y+(cap[3]-cap[1])
    for ch in text:
        draw.text((x,baseline),ch,font=font,fill=fill,anchor='ls')
        x+=font.getlength(ch)+spacing

def intros():
    y,x=np.mgrid[0:H,0:W]
    halo=np.exp(-(((x-W/2)/620)**2+((y-1060)/730)**2))
    rgb=np.empty((H,W,3),dtype=np.uint8)
    for c,(base,light) in enumerate([(5,6),(21,18),(17,17)]):rgb[:,:,c]=base+halo*light
    background=Image.fromarray(rgb).convert('RGBA')
    logo=Image.open(LOGO).convert('RGBA')
    font=ImageFont.truetype(str(EDIT/'fonts/Poppins-SemiBold.ttf'),52)
    small=ImageFont.truetype(str(EDIT/'fonts/Poppins-SemiBold.ttf'),36)
    for lang,title in [('cz','PŘEDSTAVUJE'),('en','PRESENTS')]:
        path=EDIT/f'studio-intro-{lang}-baseline.mp4'
        cmd=[str(v2.FF),'-hide_banner','-y','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgb24','-s',f'{W}x{H}','-r',str(FPS),'-i','pipe:0','-vf','scale=out_color_matrix=bt709:out_range=tv,setsar=1',*ENC,'-an','-frames:v',str(round(PREFIX*FPS)),'-movflags','+faststart',str(path)]
        with (EDIT/f'studio-intro-{lang}.log').open('wb') as log:
            p=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.DEVNULL,stderr=log)
            for n in range(round(PREFIX*FPS)):
                t=n/FPS;frame=background.copy()
                width=round(858+32*smooth(t/PREFIX))
                obj=logo.resize((width,width),Image.Resampling.LANCZOS)
                frame.alpha_composite(obj,((W-width)//2,round(610-8*smooth(t/PREFIX))))
                draw=ImageDraw.Draw(frame)
                tracking(draw,title,1660,font,(229,239,214,255),5)
                tracking(draw,'tkgames.cz',1765,small,(162,193,173,255),2)
                arr=np.array(frame.convert('RGB'))
                fade=smooth(t/.14)*smooth((PREFIX-t)/.19)
                arr=(arr.astype(np.float32)*fade).astype(np.uint8)
                if n==28:Image.fromarray(arr).save(EDIT/f'studio-intro-{lang}-poster.png')
                p.stdin.write(arr.tobytes())
            p.stdin.close();code=p.wait()
            if code:raise RuntimeError('Studio intro renderer failed')
        print('STUDIO_INTRO_READY',lang,flush=True)

def audio():
    run(['-f','lavfi','-t',PREFIX,'-i','anullsrc=r=48000:cl=stereo','-i',ROOT/'assets/audio/garden_v1/sfx/door_magic.wav','-filter_complex','[1:a]aformat=channel_layouts=stereo,volume=0.18,adelay=120|120,afade=t=out:st=0.55:d=0.35[s];[0:a][s]amix=inputs=2:duration=first:normalize=0[a]','-map','[a]','-ac','2','-c:a','pcm_s24le','studio-intro.wav'],'studio-sound')
    run(['-i','studio-intro.wav','-i',V2/'edit_project/soundtrack_v2.wav','-filter_complex',f'[0:a]aformat=channel_layouts=stereo,atrim=duration={PREFIX},asetpts=PTS-STARTPTS[a];[1:a]aformat=channel_layouts=stereo,atrim=duration=67.1,asetpts=PTS-STARTPTS[b];[a][b]concat=n=2:v=0:a=1[out]','-map','[out]','-ac','2','-c:a','pcm_s24le','soundtrack_tk_games.wav'],'full-soundtrack')

def signature():
    text='''[Script Info]\nScriptType: v4.00+\nPlayResX: 1080\nPlayResY: 2400\nScaledBorderAndShadow: yes\nYCbCr Matrix: TV.709\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\nStyle: Web,Poppins SemiBold,46,&H00D9EBCE,&H00D9EBCE,&H00152A13,&H00000000,0,0,0,0,100,100,2,0,1,2,1,5,0,0,0,1\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\nDialogue: 0,0:01:04.70,0:01:07.10,Web,,0,0,0,,{\\pos(270,2340)\\fad(200,500)}tkgames.cz\n'''
    (EDIT/'studio-signature.ass').write_text(text,encoding='utf-8-sig')

def render():
    for lang in ['cz','en']:
        body=v2.graph(lang).replace('[v]','[body]')
        fx='[2:v]scale=320:320:flags=lanczos,format=rgba,trim=duration=67.1,setpts=PTS-STARTPTS,fade=t=in:st=64.50:d=0.25:alpha=1,fade=t=out:st=66.60:d=0.5:alpha=1[logo];[body][logo]overlay=x=110:y=1980:format=auto:eof_action=pass,ass=studio-signature.ass:fontsdir=fonts,format=yuv420p[branded];[3:v]setpts=PTS-STARTPTS,fps=30,format=yuv420p[intro];[intro][branded]concat=n=2:v=1:a=0[out]'
        path=OUT/f'Bazals_Pocket_Garden_trailer_{lang.upper()}_TK_GAMES.mp4'
        run(['-i',BASE/'edit_project/picture_master.mp4','-i',V2/'edit_project/editorial_fx.mov','-loop','1','-framerate','30','-i',LOGO,'-i',EDIT/f'studio-intro-{lang}-baseline.mp4','-i','soundtrack_tk_games.wav','-filter_complex',body+';'+fx,'-map','[out]','-map','4:a:0',*ENC,'-r',FPS,'-c:a','aac','-b:a','320k','-ar','48000','-t',DURATION,'-metadata',f'title=TK Games presents Bazal’s Pocket Garden — {lang.upper()} trailer','-movflags','+faststart',path],f'export-{lang}')
        print('TK_GAMES_TRAILER_READY',lang,path,flush=True)

def verify():
    results={'duration':DURATION,'frames':FRAMES,'fps':FPS,'resolution':[W,H],'studio_intro_seconds':PREFIX,'logo':'Official unmodified transparent header PNG from tkgames.cz','logo_source_url':'https://tkgames.cz/branding/tk-games-header-transparent-1254-20261013.png','files':{}}
    for lang in ['cz','en']:
        path=OUT/f'Bazals_Pocket_Garden_trailer_{lang.upper()}_TK_GAMES.mp4'
        log=run(['-i',path,'-map','0:v:0','-map','0:a:0','-f','null','-'],f'decode-{lang}')
        count=int(re.findall(r'frame=\s*(\d+)',log)[-1])
        assert count==FRAMES and '1080x2400' in log and '30 fps' in log,(lang,count)
        assert re.search(r'Audio:\s*aac[^\n]*stereo',log),lang+' must retain stereo audio'
        assert not re.search(r'error while decoding|invalid data found|corrupt decoded frame',log,re.I)
        levels=run(['-i',path,'-vn','-af','loudnorm=I=-16.5:TP=-1.5:LRA=9:print_format=json','-f','null','-'],f'levels-{lang}')
        data=json.loads(re.search(r'\{\s*"input_i".*?\}',levels,re.S).group())
        assert float(data['input_tp'])<-.8
        results['files'][lang]={'path':str(path),'bytes':path.stat().st_size,'frames':count,'full_decode':'passed','audio':data,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        for t,name in [(1.0,'studio'),(19.6,'game'),(68.1,'end')]:
            run(['-ss',t,'-i',path,'-frames:v','1','-update','1',EDIT/f'preview-{lang}-{name}.png'],f'preview-{lang}-{name}')
    old=json.loads((V2/'verification_v2.json').read_text())
    results['approved_v2_unchanged']={lang:hashlib.sha256(Path(old['files'][lang]['file']).read_bytes()).hexdigest()==old['files'][lang]['sha256'] for lang in ['cz','en']}
    assert all(results['approved_v2_unchanged'].values())
    source=json.loads((BASE/'source-snapshot.json').read_text())
    results['game_source_unchanged']={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest()==h for p,h in source.items()}
    assert all(results['game_source_unchanged'].values())
    (OUT/'verification_tk_games.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
    shutil.copy2(__file__,EDIT/Path(__file__).name)
    print('TK_GAMES_BOTH_TRAILERS_VERIFIED',flush=True)

if __name__=='__main__':
    EDIT.mkdir(parents=True,exist_ok=True)
    prepare();intros();audio();signature();render();verify()
