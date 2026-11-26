# Referans ve uygulama görüntülerini yan yana + yarı saydam üst üste birleştirir.
import sys
from PIL import Image
ref='references/emuastro/ref_%s.jpg'; app='comparison/app_%s.png'
for n in (sys.argv[1:] or ['01','02','03','04','05','06','07','08']):
    r=Image.open(ref%n).convert('RGB'); a=Image.open(app%n).convert('RGB').resize(r.size)
    W,H=r.size; o=Image.new('RGB',(W*3,H),'white')
    o.paste(r,(0,0)); o.paste(a,(W,0)); o.paste(Image.blend(r,a,.5),(W*2,0))
    o.save('comparison/compare_%s.jpg'%n,quality=80)
    o.resize((W*3//2,H//2)).save('comparison/small_%s.jpg'%n,quality=80)
