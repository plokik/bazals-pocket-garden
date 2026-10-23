"""Arrange original art and actual native captures for human review. No retouching."""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont

repo = Path(__file__).resolve().parents[4]
proposal = Path(__file__).resolve().parents[1]
bold_path = repo / 'assets/fonts/Poppins-ExtraBold.ttf'
body_path = repo / 'assets/fonts/Poppins-SemiBold.ttf'
bold = ImageFont.truetype(str(bold_path), 24)
body = ImageFont.truetype(str(body_path), 17)
ink = '#294334'
items = [('lavender-sachet-v1.png', 'Levandulový sáček'),
         ('mint-lemonbalm-tea-v1.png', 'Mátovo-meduňkový čaj'),
         ('herbal-gift-v1.png', 'Dárkový balíček bylin')]
board = Image.new('RGB', (1080, 430), '#f4f6df')
draw = ImageDraw.Draw(board)
draw.text((32, 20), 'NOVÉ VÝROBKY DO BAZALOVY DÍLNY', font=bold, fill=ink)
draw.text((32, 58), 'Malovaný návrh ke schválení', font=body, fill=ink)
alpha_report = []
for index, (filename, title) in enumerate(items):
    source = Image.open(proposal / 'art' / filename).convert('RGBA')
    alpha = source.getchannel('A')
    histogram = alpha.histogram()
    alpha_report.append({'file':filename,'size':source.size,'transparent_pixels':histogram[0],
                         'semi_transparent_pixels':sum(histogram[1:255]),'alpha_bbox':alpha.getbbox()})
    assert histogram[0] > source.width * source.height * .15
    assert source.getpixel((0,0))[3] == 0
    source.thumbnail((290, 270), Image.Resampling.LANCZOS)
    x = index * 360 + (360-source.width)//2
    y = 95 + (270-source.height)//2
    board.paste(source,(x,y),source)
    title_font = ImageFont.truetype(str(bold_path), 20)
    draw.text((index*360+180,383),title,font=title_font,fill=ink,anchor='mm')
board.save(proposal / 'vyrobky-ke-schvaleni.png')

screens = Image.new('RGB',(744,850),'#f4f6df')
d = ImageDraw.Draw(screens)
small_bold = ImageFont.truetype(str(bold_path), 16)
d.text((12,12),'VÝROBEK V DÍLNĚ',font=small_bold,fill=ink)
d.text((384,12),'ZAKÁZKA PŘIPRAVENÁ K PŘEDÁNÍ',font=small_bold,fill=ink)
for x, name in [(12,'product-tea-360.png'),(384,'teahouse-ready-360.png')]:
    capture = Image.open(proposal/name).convert('RGB')
    assert capture.size == (360,800)
    screens.paste(capture,(x,42))
screens.save(proposal/'nahledy-godot.png')
(proposal/'art/alpha-verification.json').write_text(json.dumps(alpha_report,ensure_ascii=False,indent=2),encoding='utf-8')
print('TEAHOUSE_REVIEW_ARTIFACTS=PASSED')
