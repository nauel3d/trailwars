"""Prepare review PNG inputs with explicit licensed font glyphs.
Raw mockups/*.svg keeps editable text and an embedded OFL font for browsers.
This renderer avoids the host SVG library's incorrect monospace fallback.
"""
from pathlib import Path
from PIL import Image,ImageFont,ImageDraw,ImageColor
import xml.etree.ElementTree as ET
import base64,io,math,json
PLAN=Path(__file__).resolve().parent.parent
NS='http://www.w3.org/2000/svg';XL='http://www.w3.org/1999/xlink'
ET.register_namespace('',NS);ET.register_namespace('xlink',XL)
out=PLAN/'qa/raster-input';out.mkdir(exist_ok=True)
fonts={'Fredoka One':PLAN/'source/fonts/FredokaOne-Regular.ttf','Arial':Path('C:/Windows/Fonts/arial.ttf')}
count=0
for file in (PLAN/'mockups').glob('*.svg'):
 tree=ET.parse(file);root=tree.getroot()
 for parent in list(root.iter()):
  for item in list(parent):
   if item.tag!='{'+NS+'}text':continue
   index=list(parent).index(item);parent.remove(item)
   size=round(float(item.get('font-size','22')));family=item.get('font-family','Arial')
   font=ImageFont.truetype(str(fonts.get(family,fonts['Arial'])),size)
   fill=ImageColor.getrgb(item.get('fill','#3D1B39'));stroke=item.get('stroke');sw=round(float(item.get('stroke-width','0'))) if stroke else 0
   base=float(item.get('y','0'));anchor=item.get('text-anchor','start')
   for line in item:
    value=line.text or '';base+=float(line.get('dy','0'));tx=float(line.get('x',item.get('x','0')))
    length=font.getlength(value)
    if anchor=='middle':tx-=length/2
    elif anchor=='end':tx-=length
    box=font.getbbox(value or ' ',anchor='ls',stroke_width=sw)
    width=max(1,math.ceil(box[2]-box[0]+4));height=max(1,math.ceil(box[3]-box[1]+4))
    image=Image.new('RGBA',(width,height));d=ImageDraw.Draw(image)
    d.text((2-box[0],2-box[1]),value,font=font,anchor='ls',fill=fill,stroke_width=sw,stroke_fill=ImageColor.getrgb(stroke) if stroke else None)
    data=io.BytesIO();image.save(data,format='PNG')
    node=ET.Element('{'+NS+'}image',{'x':str(tx+box[0]-2),'y':str(base+box[1]-2),'width':str(width),'height':str(height),'{'+XL+'}href':'data:image/png;base64,'+base64.b64encode(data.getvalue()).decode()})
    parent.insert(index,node);index+=1;count+=1
 tree.write(out/file.name,encoding='utf-8',xml_declaration=True)
print(json.dumps({'explicitFontGlyphLayers':count,'screens':len(list(out.glob('*.svg')))}))
