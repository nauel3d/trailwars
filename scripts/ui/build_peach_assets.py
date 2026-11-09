"""Editable local reconstruction of the user-approved artwork, never a screen sprite.
Run from project root. Pillow/numpy/scipy are development tools only.
The locked artwork supplies the logo/icons; named skin layers remain editable below.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
from scipy import ndimage
import json, hashlib, math, base64

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT/'assets/peach'
DESIGN = ROOT/'design/approved-customize'
REF = Image.open(ROOT/'design/reference/approved_customize_1672x941.png').convert('RGB')
OUT.mkdir(parents=True, exist_ok=True)
AA=3
manifest={}
def save(name, image, slices=None):
    image.save(OUT/(name+'.png'),optimize=True)
    manifest[name]={'file':name+'.png','size':list(image.size),'sha256':hashlib.sha256((OUT/(name+'.png')).read_bytes()).hexdigest()}
    if slices: manifest[name]['sliceCenter']=slices

def matte(name,box,kind='peach'):
    im=REF.crop(box).convert('RGBA'); a=np.asarray(im).copy(); rgb=a[:,:,:3].astype(float)
    r,g,b=[rgb[:,:,i] for i in range(3)]
    if kind=='peach': bg=(r>175)&(g>94)&(b>65)&(r>g)&(g>b)
    elif kind=='orange': bg=(r>160)&(g<205)&(b<115)
    else: bg=(g<115)&(r<180)&(b<180)&(b>g*.7)
    labels,_=ndimage.label(bg)
    ids=np.unique(np.concatenate([labels[0],labels[-1],labels[:,0],labels[:,-1]])); ids=ids[ids!=0]
    outside=np.isin(labels,ids)
    alpha=(~outside).astype(np.uint8)*255
    # Preserve rounded antialiasing without retaining a rectangular background.
    a[:,:,3]=alpha
    save(name,Image.fromarray(a))

def gradient(size,top,bottom):
    w,h=size; t=np.linspace(0,1,h)[:,None,None]
    c=np.array(top)[None,None,:]*(1-t)+np.array(bottom)[None,None,:]*t
    c=np.repeat(c,w,axis=1).astype(np.uint8)
    return Image.fromarray(c,'RGB').convert('RGBA')
def shell(name,size,radius,colors,selected=False,frame=False):
    w,h=size; W,H=w*AA,h*AA
    out=Image.new('RGBA',(W,H)); box=(10*AA,4*AA,(w-10)*AA,(h-14)*AA)
    shadow=Image.new('RGBA',(W,H)); d=ImageDraw.Draw(shadow)
    d.rounded_rectangle((box[0],box[1]+8*AA,box[2],box[3]+8*AA),radius*AA,fill=(103,40,13,100))
    out.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(5*AA)))
    d=ImageDraw.Draw(out); edge=(16,239,212,255) if selected else colors[0]
    d.rounded_rectangle(box,radius*AA,fill=edge)
    inner=(box[0]+4*AA,box[1]+3*AA,box[2]-4*AA,box[3]-7*AA)
    mask=Image.new('L',(W,H)); ImageDraw.Draw(mask).rounded_rectangle(inner,max(4,radius-4)*AA,fill=255)
    fill=gradient((W,H),colors[1],colors[2]);out.alpha_composite(Image.composite(fill,Image.new('RGBA',(W,H)),mask))
    d=ImageDraw.Draw(out)
    d.rounded_rectangle((box[0]+2*AA,box[1]+AA,box[2]-2*AA,box[3]-4*AA),max(4,radius-2)*AA,outline=(255,246,223,170),width=2*AA)
    d.line((box[0]+radius*AA,box[1]+5*AA,box[2]-radius*AA,box[1]+5*AA),fill=(255,255,239,145),width=2*AA)
    if frame:
        inset=31*AA
        hole=(box[0]+inset,box[1]+inset,box[2]-inset,box[3]-inset)
        d.rounded_rectangle(hole,max(10,radius-30)*AA,fill=(0,0,0,0))
    out=out.resize(size,Image.Resampling.LANCZOS)
    x=min(radius+18,w//2-1);y=min(radius+12,h//2-1)
    save(name,out,[x,y,w-x,h-y])

plum=((116,57,96,255),(102,47,86),(45,24,45))
orange=((213,76,5,255),(255,158,40),(245,87,0))
cream=((224,147,94,255),(255,241,212),(255,206,161))
teal=((0,135,120,255),(35,231,201),(0,168,148))
shell('button_plum',(360,128),55,plum)
shell('button_orange',(512,128),55,orange)
shell('card_plum',(512,196),45,plum)
shell('card_selected',(512,196),45,plum,True)
shell('pill_cream',(300,82),35,cream)
shell('pill_teal',(180,66),28,teal)
shell('frame_cream',(760,560),96,cream,frame=True)
shell('tab_orange',(160,60),25,orange)
shell('tab_teal',(160,60),25,teal)

# Actual original logo and symbols, isolated as individual layers.
matte('logo',(22,25,367,274))
matte('icon_play',(49,302,137,393),'plum')
matte('icon_customize',(46,424,135,506),'plum')
matte('icon_shop',(47,542,130,623),'orange')
matte('icon_profile',(49,669,129,743),'plum')
matte('icon_settings',(48,782,132,858),'plum')
matte('coin',(608,342,658,393),'peach')
# A smooth ring asset authored as a reusable independent cosmetic, identical hitbox.
def core(name,ring=True):
    size=160; out=Image.new('RGBA',(size*AA,size*AA)); d=ImageDraw.Draw(out)
    d.ellipse((14*AA,18*AA,146*AA,150*AA),fill=(0,52,46,110))
    d.ellipse((12*AA,8*AA,148*AA,144*AA),fill=(0,130,119,255))
    d.ellipse((16*AA,10*AA,144*AA,138*AA),fill=(30,229,203,255))
    d.arc((19*AA,13*AA,141*AA,135*AA),192,345,fill=(167,255,237,255),width=4*AA)
    if ring:
        d.ellipse((44*AA,40*AA,116*AA,113*AA),fill=(0,111,105,255))
        d.ellipse((47*AA,43*AA,113*AA,109*AA),fill=(0,0,0,0))
    save(name,out.resize((size,size),Image.Resampling.LANCZOS))
core('ring');core('core',False)

# Independent decorative preview paths. No gameplay or collision implementation.
def bezier(points,n=70):
    return [tuple(sum(math.comb(3,k)*(1-t)**(3-k)*t**k*points[k][j] for k in range(4)) for j in range(2)) for t in np.linspace(0,1,n)]
def route(name,curves):
    im=Image.new('RGBA',(700*AA,460*AA));d=ImageDraw.Draw(im)
    points=[]
    for curve in curves: points+=bezier(curve)
    p=[(round(x*AA),round(y*AA)) for x,y in points]
    d.line([(x,y+3*AA) for x,y in p],fill=(0,0,0,90),width=13*AA,joint='curve')
    d.line(p,fill=(255,255,255,255),width=8*AA,joint='curve')
    save(name,im.resize((700,460),Image.Resampling.LANCZOS))
route('route_orange',[[(0,340),(45,340),(40,340),(40,290)],[(40,290),(40,50),(20,64),(110,64)],[(110,64),(220,64),(255,64),(360,64)]])
route('route_teal',[[(0,392),(150,392),(142,392),(142,292)],[(142,292),(142,205),(150,206),(223,206)],[(223,206),(300,206),(349,206),(400,206)]])
route('route_cream',[[(225,460),(225,410),(225,390),(286,390)],[(286,390),(475,390),(582,390),(582,305)]])
route('route_dashed',[[(50,260),(220,260),(170,120),(350,120)]])

# Tileable original plum grain, separate from all preview content.
rng=np.random.default_rng(4); noise=rng.normal(0,1.5,(128,128,1));base=np.array([57,31,56])[None,None,:]
tex=np.clip(base+noise,0,255).astype('uint8');save('plum_texture',Image.fromarray(tex))
save('peach_gradient',gradient((256,256),(255,217,182),(255,192,148)))

# Reconstruct empty normal-button skin using the approved clean gap between its
# icon and text. Preserve the source cap/border pixels, remove every baked label.
def reference_skin(name,box,sample_x):
    im=REF.crop(box).convert('RGBA');w,h=im.size
    source=np.asarray(REF)[:,sample_x-2:sample_x+2,:].mean(axis=1).astype('uint8')
    strip=np.repeat(source[box[1]:box[3],None,:],w,axis=1)
    fill=Image.fromarray(strip).convert('RGBA')
    mask=Image.new('L',(w,h));d=ImageDraw.Draw(mask)
    d.rounded_rectangle((12,8,w-13,h-20),radius=min(48,h//2-10),fill=255)
    im=Image.composite(fill,im,mask)
    alpha=Image.new('L',(w,h));ImageDraw.Draw(alpha).rounded_rectangle((0,0,w-1,h-9),radius=min(56,h//2),fill=255)
    im.putalpha(alpha)
    save(name,im,[60,54,w-60,h-54])
reference_skin('button_plum',(18,282,369,410),142)

# The preview's original cream sculpted rim is its own layer with a transparent
# centre, independent of all three trail layers and cores.
frame_box=(907,145,1652,700); im=REF.crop(frame_box).convert('RGBA');w,h=im.size
mask=Image.new('L',(w,h));d=ImageDraw.Draw(mask)
d.rounded_rectangle((0,8,w-2,h-8),radius=110,fill=255)
d.rounded_rectangle((37,55,w-36,h-43),radius=76,fill=0)
im.putalpha(mask);save('frame_cream',im,[134,124,w-134,h-124])

# Approved-material generation is preserved verbatim as editable source. Explicit
# masks isolate each skin and remove the generator's unwanted background pixels.
kit_path=DESIGN/'generated-skin-source.png'
if kit_path.exists():
    kit=Image.open(kit_path).convert('RGBA')
    def cut_skin(name,box,body,radius,slices,hole=None):
        image=kit.crop(box);mask=Image.new('L',image.size);d=ImageDraw.Draw(mask)
        d.rounded_rectangle(body,radius=radius,fill=255)
        if hole:d.rounded_rectangle(hole[0],radius=hole[1],fill=0)
        image.putalpha(mask.filter(ImageFilter.GaussianBlur(.65)))
        save(name,image,slices)
    cut_skin('button_plum',(40,80,725,316),(16,20,668,214),97,[120,104,565,130])
    cut_skin('button_orange',(756,80,1496,316),(12,20,719,214),97,[120,104,620,130])
    cut_skin('card_selected',(746,473,1505,832),(10,10,750,342),58,[90,90,669,269])
    cut_skin('frame_cream',(20,376,745,955),(16,14,711,563),112,[135,135,590,444],(((74,75,665,514)),77))
    # Unselected cards share the same plum material as navigation, not new art.
    save('card_plum',Image.open(OUT/'button_plum.png'),[120,104,565,130])
neutral=Image.open(OUT/'core.png').convert('RGBA');a=np.asarray(neutral).copy()
lum=a[:,:,:3].max(axis=2);a[:,:,:3]=lum[:,:,None];save('core_neutral',Image.fromarray(a))
def teal_cut(name,box):
    image=REF.crop(box).convert('RGBA');a=np.asarray(image).copy();rgb=a[:,:,:3].astype(float)
    alpha=((rgb[:,:,1]>rgb[:,:,0]*1.13)&(rgb[:,:,2]>rgb[:,:,0]*1.13)&(rgb[:,:,1]>65)).astype('uint8')*255
    a[:,:,3]=alpha;save(name,Image.fromarray(a))
teal_cut('ring',(403,279,560,438))
teal_cut('dashed_icon',(395,478,566,582))
teal_cut('starter_trail_icon',(400,827,503,868))

(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
# Scene layers are separate image elements and native-editable text, never one screenshot.
layers=[('logo','logo',22,25,345,249),('play','button_plum',14,282,360,128),('customize','button_plum',14,409,360,128),('shop','button_orange',14,524,360,128),('profile','button_plum',14,649,360,128),('settings','button_plum',14,766,360,128),('ring-card','card_selected',374,242,512,196),('trail-card','card_plum',374,447,512,176),('preview-frame','frame_cream',904,144,752,560),('view-item','button_orange',1032,708,528,132),('starter-core','pill_cream',378,704,512,94),('starter-trail','pill_cream',378,803,512,94)]
svg=['<svg xmlns="http://www.w3.org/2000/svg" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" width="1672" height="941" viewBox="0 0 1672 941">','<rect width="1672" height="941" fill="#FFD4AD"/>']
for label,name,x,y,w,h in layers:
    data=base64.b64encode((OUT/(name+'.png')).read_bytes()).decode()
    svg.append(f'<g id="{label}" inkscape:groupmode="layer" inkscape:label="{label}"><image href="data:image/png;base64,{data}" x="{x}" y="{y}" width="{w}" height="{h}"/></g>')
svg.append('<g id="editable-type" font-family="Fredoka One" font-weight="bold" fill="#FFF3DF"><text x="150" y="364" font-size="48">PLAY</text><text x="146" y="487" font-size="38">CUSTOMIZE</text><text x="150" y="605" font-size="48">SHOP</text><text x="145" y="727" font-size="40">PROFILE</text><text x="145" y="848" font-size="40">SETTINGS</text><text x="587" y="326" font-size="46">RING CORE</text><text x="587" y="508" font-size="43">DASHED TRAIL</text></g></svg>')
(DESIGN/'customize.layers.svg').write_text('\n'.join(svg),encoding='utf-8')
(DESIGN/'geometry.json').write_text(json.dumps({'canvas':[1672,941],'layers':[{'name':label,'asset':name,'rect':[x,y,w,h]} for label,name,x,y,w,h in layers]},indent=2)+'\n',encoding='utf-8')
print(f'Generated {len(manifest)} separate assets and editable scene layers.')
