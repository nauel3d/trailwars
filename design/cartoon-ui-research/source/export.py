"""Render font-faithful preview layers; keep original SVG text editable."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageColor
import xml.etree.ElementTree as E
import base64,io,math,json,re
R=Path(__file__).resolve().parent.parent
N='http://www.w3.org/2000/svg';X='http://www.w3.org/1999/xlink'
E.register_namespace('',N);E.register_namespace('xlink',X)
out=R/'qa/raster-input';out.mkdir(exist_ok=True)
fred=R/'source/fonts/FredokaOne-Regular.ttf'
for page in json.loads((R/'manifest.json').read_text()):
 f=R/page['file'];tree=E.parse(f);root=tree.getroot();ink={'A':'#20334C','B':'#343A32','C':'#243C54'}[page['concept']]
 for parent in list(root.iter()):
  for el in list(parent):
   if el.tag!='{'+N+'}text':continue
   text=''.join(el.itertext());sz=round(float(el.get('font-size','18')))
   font=ImageFont.truetype(str(Path('C:/Windows/Fonts/arial.ttf') if el.get('class')=='body' else R/'source/fonts/Kalam-Bold.ttf' if page['concept']=='B' else fred),sz*2)
   color=ink
   if 'style' in el.attrib:color=el.attrib['style'].split('fill:')[-1].split(';')[0]
   bbox=font.getbbox(text or ' ',anchor='ls');tw=font.getlength(text)/2;x=float(el.get('x','0'));y=float(el.get('y','0'))
   if el.get('text-anchor')=='middle':x-=tw/2
   elif el.get('text-anchor')=='end':x-=tw
   im=Image.new('RGBA',(max(1,math.ceil(bbox[2]-bbox[0]+4)),max(1,math.ceil(bbox[3]-bbox[1]+4))))
   ImageDraw.Draw(im).text((2-bbox[0],2-bbox[1]),text,font=font,anchor='ls',fill=ImageColor.getrgb(color))
   buf=io.BytesIO();im.save(buf,format='PNG')
   new=E.Element('{'+N+'}image',{'x':str(x+bbox[0]/2-1),'y':str(y+bbox[1]/2-1),'width':str(im.width/2),'height':str(im.height/2),'{'+X+'}href':'data:image/png;base64,'+base64.b64encode(buf.getvalue()).decode()})
   idx=list(parent).index(el);parent.remove(el);parent.insert(idx,new)
 tree.write(out/(page['id']+'.svg'),encoding='utf-8',xml_declaration=True)
print('Prepared font-faithful exports')
