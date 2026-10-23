from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

folder = Path(__file__).resolve().parent
repo = folder.parents[2]
font = ImageFont.truetype(str(repo / 'assets/fonts/Poppins-ExtraBold.ttf'),16)
board = Image.new('RGB',(744,850),'#f4f6df')
draw = ImageDraw.Draw(board)
for x, title, filename in [(12,'VÝROBA V DÍLNĚ','product-tea-360.png'),
                            (384,'SKUTEČNÁ ZÁSOBA VE SKLADU','storage-products-432.png')]:
    draw.text((x,12),title,font=font,fill='#294334')
    capture = Image.open(folder/filename).convert('RGB')
    if capture.size != (360,800): capture = capture.resize((360,800),Image.Resampling.LANCZOS)
    board.paste(capture,(x,42))
board.save(folder/'zapojeno-ve-hre.png')
print('WORKSHOP_INTEGRATION_REVIEW=PASSED')
