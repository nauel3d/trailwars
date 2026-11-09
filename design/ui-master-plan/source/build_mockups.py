"""Author editable review mockups, not Roblox runtime code.
Each screen is an independent SVG with named layers, editable text and separate
skin assets. PNGs are rendered by render_mockups.mjs. No Studio calls or uploads.
"""
from pathlib import Path
from PIL import ImageFont,Image
import json, html, math,base64,hashlib

ROOT=Path(__file__).resolve().parents[3]
PLAN=ROOT/'design/ui-master-plan'
OUT=PLAN/'mockups';OUT.mkdir(exist_ok=True)
ASSETS=json.loads((ROOT/'assets/peach/manifest.json').read_text())
FONT=PLAN/'source/fonts/FredokaOne-Regular.ttf'
BODY=Path('C:/Windows/Fonts/arial.ttf')
P={'peach':'#FFD0A7','cream':'#FFF1DA','plum':'#3D1B39','well':'#42203F','orange':'#FF7700','teal':'#00DABA','coral':'#B64435'}
CAT=[('Starter core','core',None,'OWNED'),('Ring core','ring',150,'LOCKED'),('Starter trail','starter_trail_icon',None,'OWNED'),('Dashed trail','dashed_icon',100,'LOCKED')]
PAGES=[]
def esc(s):return html.escape(str(s),quote=True)
def fm(size,body=False):return ImageFont.truetype(str(BODY if body else FONT),int(size))

class Screen:
 def __init__(self,slug,title,w=1672,h=941,active='',kind='menu',note='DESIGN PROPOSAL · SAMPLE DATA'):
  self.slug,self.title,self.w,self.h,self.active,self.kind=slug,title,w,h,active,kind
  self.parts=[];self.boxes=[];self.actions=[];self.warnings=[]
  self.parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><title>{esc(title)} — Trail Wars design proposal</title><defs><linearGradient id="peach" x2="0" y2="1"><stop stop-color="#FFDCBB"/><stop offset="1" stop-color="#FFBE91"/></linearGradient><linearGradient id="well" x2="0" y2="1"><stop stop-color="#532747"/><stop offset="1" stop-color="#291C34"/></linearGradient><filter id="soft"><feDropShadow dx="0" dy="5" stdDeviation="5" flood-color="#803A1D" flood-opacity=".22"/></filter><clipPath id="ringclip"><ellipse cx="78.5" cy="73" rx="76" ry="71"/></clipPath></defs>')
  self.parts.append('<style>@font-face{font-family:"Fredoka One";src:url(data:font/ttf;base64,'+base64.b64encode(FONT.read_bytes()).decode()+')}text{font-synthesis:none}</style>')
  self.rect(0,0,w,h,'url(#peach)')
  self.parts.append(f'<ellipse cx="{w*.48}" cy="-36" rx="{w*.14}" ry="82" fill="#FF9432"/><ellipse cx="{w+82}" cy="{h*.45}" rx="150" ry="220" fill="#27C7B2" opacity=".85"/>')
  self.text(note,14,h-15,w-28,13,color=P['plum'],body=True,align='center',key='proposal-label')
 def rect(self,x,y,w,h,fill,rx=0,stroke=None,sw=1):
  self.parts.append(f'<rect x="{x}" y="{y}" width="{max(0,w)}" height="{max(0,h)}" rx="{rx}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>')
 def image(self,key,x,y,w,h,clip=False):
  data=ASSETS[key];url='../../../assets/peach/'+data['file']
  if clip:
   self.parts.append(f'<svg x="{x}" y="{y}" width="{w}" height="{h}" viewBox="0 0 157 159"><image xlink:href="{url}" width="157" height="159" clip-path="url(#ringclip)"/></svg>')
  else:self.parts.append(f'<image x="{x}" y="{y}" width="{w}" height="{h}" preserveAspectRatio="none" xlink:href="{url}"/>')
 def skin(self,key,x,y,w,h,scale=.55):
  if key=='pill_cream' and h>180:
   self.rect(x+10,y+10,w-20,h-25,'#FFE5C7',38)
   self.image('frame_cream',x,y,w,h)
   return
  # Export the exact 9-slice composition to a named review skin. This avoids
  # Cairo's degenerate nested-viewport seams; text remains an editable SVG layer.
  cache=PLAN/'source/skin-exports';cache.mkdir(exist_ok=True)
  name=key+'-'+hashlib.sha256(f'{w},{h},{scale}'.encode()).hexdigest()[:12]+'.png'
  file=cache/name
  if not file.exists():
   a=ASSETS[key];sw,sh=a['size'];s=a.get('sliceCenter')
   if s:
    l,t,r,b=s;dw,dh=round(w),round(h);caps=[l*scale,t*scale,(sw-r)*scale,(sh-b)*scale]
    k=min(1,dw/max(caps[0]+caps[2],1),dh/max(caps[1]+caps[3],1));caps=[round(v*k) for v in caps]
    dx=[0,caps[0],dw-caps[2],dw];dy=[0,caps[1],dh-caps[3],dh];sx=[0,l,r,sw];sy=[0,t,b,sh]
    im=Image.open(ROOT/'assets/peach'/a['file']).convert('RGBA');result=Image.new('RGBA',(dw,dh))
    for row in range(3):
     for col in range(3):
      ww,hh=dx[col+1]-dx[col],dy[row+1]-dy[row]
      if ww<1 or hh<1:continue
      piece=im.crop((sx[col],sy[row],sx[col+1],sy[row+1])).convert('RGBa').resize((ww,hh),Image.Resampling.LANCZOS).convert('RGBA')
      result.alpha_composite(piece,(dx[col],dy[row]))
    result.save(file)
   else:Image.open(ROOT/'assets/peach'/a['file']).save(file)
  self.parts.append(f'<image x="{x}" y="{y}" width="{w}" height="{h}" preserveAspectRatio="none" xlink:href="../source/skin-exports/{name}"/>')
  return
  a=ASSETS[key];sw,sh=a['size'];s=a.get('sliceCenter')
  if not s:self.image(key,x,y,w,h);return
  l,t,r,b=s;dL,dT,dR,dB=l*scale,t*scale,(sw-r)*scale,(sh-b)*scale
  k=min(1,w/max(dL+dR,1),h/max(dT+dB,1));dL*=k;dT*=k;dR*=k;dB*=k
  sx=[0,l,r,sw];sy=[0,t,b,sh];dx=[x,x+dL,x+w-dR,x+w];dy=[y,y+dT,y+h-dB,y+h]
  self.parts.append(f'<g id="skin-{len(self.parts)}">')
  for row in range(3):
   for col in range(3):
    if dx[col+1]-dx[col]<.5 or dy[row+1]-dy[row]<.5:continue
    self.parts.append(f'<svg x="{dx[col]}" y="{dy[row]}" width="{max(.01,dx[col+1]-dx[col])}" height="{max(.01,dy[row+1]-dy[row])}" viewBox="{sx[col]} {sy[row]} {sx[col+1]-sx[col]} {sy[row+1]-sy[row]}" preserveAspectRatio="none"><image width="{sw}" height="{sh}" xlink:href="../../../assets/peach/{a["file"]}"/></svg>')
  self.parts.append('</g>')
 def text(self,value,x,y,w,size=22,color=None,body=False,align='left',maxlines=4,key=None,outline=False):
  font=fm(size,body);lines=[]
  for paragraph in str(value).split('\n'):
   words=paragraph.split();line=''
   for word in words:
    test=(line+' '+word).strip()
    if line and font.getlength(test)>w:lines.append(line);line=word
    else:line=test
   lines.append(line)
  if len(lines)>maxlines:self.warnings.append({'text':value,'reason':'too many wrapped lines','lines':len(lines),'max':maxlines})
  anchor={'left':'start','center':'middle','right':'end'}[align];tx=x if align=='left' else x+w/2 if align=='center' else x+w
  family='Arial' if body else 'Fredoka One';c=color or P['plum'];lh=size*1.22
  extra=' paint-order="stroke" stroke="#5D2D3D" stroke-width="2" stroke-linejoin="round"' if outline else ''
  self.parts.append(f'<text x="{tx}" y="{y+size}" font-family="{family}" font-size="{size}" fill="{c}" text-anchor="{anchor}"{extra}>')
  for i,line in enumerate(lines):self.parts.append(f'<tspan x="{tx}" dy="{0 if i==0 else lh}">{esc(line)}</tspan>')
  self.parts.append('</text>')
  if key:self.boxes.append({'id':key,'rect':[x,y,w,len(lines)*lh],'text':value,'fontSize':size})
  return len(lines)*lh
 def button(self,label,x,y,w,h,variant='plum',action=None,selected=False,disabled=False,size=None):
  self.parts.append(f'<g id="control-{esc(action or label)}"'+(' opacity=".48"' if disabled else '')+'>')
  self.skin('button_orange' if variant=='orange' else 'button_plum',x,y,w,h,.55)
  if selected:self.rect(x+8,y+5,w-16,h-20,'none',max(16,h*.3),P['teal'],3)
  fs=size or (26 if self.w>700 else 20)
  self.text(label,x+14,y+(h-fs*1.22)/2-3,w-28,fs,P['cream'],align='center',maxlines=2,outline=variant=='orange')
  self.parts.append('</g>')
  if action:self.actions.append({'id':action,'rect':[x,y,w,h],'label':label,'disabled':disabled})
 def pill(self,label,x,y,w=150,h=52,teal=False,size=22):
  self.skin('pill_teal' if teal else 'pill_cream',x,y,w,h,1)
  self.text(label,x+10,y+(h-size*1.2)/2-3,w-20,size,P['cream'] if teal else P['plum'],align='center',maxlines=1)
 def logo(self,x,y,w):self.image('logo',x,y,w,w*249/345)
 def shell(self,title=None,active=None,balance='480 COINS'):
  active=active or self.active;w,h=self.w,self.h
  if w>=1100:
   rail=250;self.logo(16,12,250)
   self.button('HOW TO PLAY' if self.slug.startswith('01-home') else '‹ HOME',300,16,218,66,action='Home' if not self.slug.startswith('01-home') else 'Controls',size=23)
   self.skin('button_plum',w-350,12,320,78,.55);self.image('coin',w-328,30,40,40)
   self.text(balance,w-276,27,220,26,P['cream'],align='center',maxlines=2)
   for i,(lab,icon) in enumerate([('CUSTOMIZE','icon_customize'),('SHOP','icon_shop'),('PROFILE','icon_profile'),('SETTINGS','icon_settings')]):
    y=260+i*112;self.button('',16,y,250,94,'orange' if active==lab else 'plum',action=lab,size=25)
    self.image(icon,35,y+23,43,43)
    self.text(lab,87,y+29,160,22,P['cream'],align='center',maxlines=1)
   self.main=(300,130,w-332,h-166)
  else:
   self.logo(8,5,min(118,w*.32));self.skin('button_plum',w-204,8,196,60,.55);self.image('coin',w-190,22,28,28)
   self.text(balance,w-157,22,140,18,P['cream'],align='center',maxlines=1)
   self.button('CONTROLS' if self.title=='Home' else '‹ HOME',w-140,76,132,50,action='Controls' if self.title=='Home' else 'Home',size=18)
   self.main=(16,142,w-32,h-174)
  if title:
   x,y,mw,mh=self.main;self.skin('pill_cream',x,y-6,min(mw,1040),84 if w>1100 else 54,1)
   self.text(title,x+18,y+5,min(mw,1040)-36,44 if w>1100 else 28,key='screen-title')
  return self.main
 def arena(self,x,y,w,h,hud=False,muted=False):
  self.parts.append(f'<g id="independent-arena-{len(self.parts)}">')
  holex,holey,holew,holeh=x+w*72/725,y+h*72/579,w*595/725,h*445/579
  self.parts.append(f'<rect x="{holex}" y="{holey}" width="{holew}" height="{holeh}" rx="{w*78/725}" ry="{h*78/579}" fill="url(#well)"/>')
  # Smooth continuous wall paths, each ending behind its own core. No branches.
  iw,ih=holew*.97,holeh*.96;ox,oy=holex+2,holey+2
  def pt(a,b):return (ox+iw*a,oy+ih*b)
  routes=[('orange',[(0,.26),(.10,.26),(.12,.14),(.28,.14),(.37,.14)]),('teal',[(0,.76),(.18,.76),(.24,.66),(.24,.45),(.58,.45)]),('cream',[(.32,1),(.32,.84),(.42,.84),(.78,.84),(.86,.63)])]
  for color,coords in routes:
   p=[pt(*q) for q in coords];c=P.get(color,color)
   d=f'M {p[0][0]} {p[0][1]} C {p[1][0]} {p[0][1]} {p[1][0]} {p[2][1]} {p[2][0]} {p[2][1]} S {p[3][0]} {p[3][1]} {p[4][0]} {p[4][1]}'
   self.parts.append(f'<path d="{d}" fill="none" stroke="{c}" stroke-width="{max(4,min(8,w*.009))}" stroke-linecap="round" opacity="{.55 if muted else 1}"/>')
   cx,cy=p[4];r=max(12,min(24,w*.027))
   if color=='teal':
    self.parts.append(f'<circle cx="{cx+r}" cy="{cy}" r="{r}" fill="#40223D" stroke="{P["teal"]}" stroke-width="{max(5,r*.36)}"/>')
    if not muted:self.pill('YOU',cx+r-34,cy-r-40,68,36,True,16)
   else:self.parts.append(f'<circle cx="{cx}" cy="{cy}" r="{r*.8}" fill="{c}" stroke="#FFE2BD" stroke-width="2"/>')
  self.image('frame_cream',x,y,w,h)
  if not hud:
   self.skin('tab_orange',x+w/2-62,y-3,124,43,1)
   self.skin('tab_teal',x+w/2-63,y+h-42,126,44,1)
  self.parts.append('</g>')
 def panel(self,x,y,w,h,title=None):
  self.skin('card_plum',x,y,w,h,.55)
  if title:self.text(title,x+22,y+16,w-44,25 if self.w>700 else 21,P['cream'])
 def item(self,index,x,y,w,h,selected=False,owned=None):
  name,key,price,state=CAT[index]
  self.skin('card_selected' if selected else 'card_plum',x,y,w,h,.55)
  size=min(96,w*.46,h*.47)
  aw=size*1.35 if key=='starter_trail_icon' else size;ah=aw*41/103 if key=='starter_trail_icon' else aw*104/171 if key=='dashed_icon' else size
  self.image(key,x+(w-aw)/2,y+12+(size-ah)/2,aw,ah,clip=key=='ring')
  fs=23 if w>230 else 16
  self.text(name.upper(),x+12,y+size+20,w-24,fs,P['cream'],align='center',maxlines=2)
  label='✓ OWNED' if (owned if owned is not None else state=='OWNED') else str(price)+' COINS'
  self.pill(label,x+14,y+h-60,w-28,48,teal=label.startswith('✓'),size=20 if w>230 else 16)
  self.actions.append({'id':'item-'+str(index),'rect':[x,y,w,h],'label':name,'disabled':False})
 def export(self,purpose,states,transform='',status='proposal'):
  self.parts.append('</svg>');(OUT/(self.slug+'.svg')).write_text('\n'.join(self.parts),encoding='utf-8')
  data={'slug':self.slug,'title':self.title,'viewport':[self.w,self.h],'purpose':purpose,'states':states,'responsive':transform,'status':status,'actions':self.actions,'textBoxes':self.boxes,'warnings':self.warnings,'kind':self.kind}
  PAGES.append(data)

def home(w=1672,h=941,slug='01-home-desktop'):
 s=Screen(slug,'Home',w,h,active='HOME');s.shell(balance='480 COINS')
 if w>=1100:
  x,y,mw,mh=s.main
  s.skin('pill_cream',x+15,y,mw-30,108,1)
  s.text('BATTLE WITH TRAILS!',x+38,y+7,mw-76,64,align='center',maxlines=1)
  s.arena(x+15,y+128,mw-30,mh-300)
  s.text('Steer left or right. Last core standing wins.',x+20,h-168,mw-40,24,align='center')
  s.button('PLAY',x+mw*.17,h-120,mw*.66,92,'orange','Play',size=48)
 elif w>=600:
  # Compact landscape has a different composition, not a scaled desktop.
  s=Screen(slug,'Home · compact landscape',w,h)
  s.logo(10,3,110);s.text('480 COINS',w-200,14,180,19,align='right')
  s.text('BATTLE WITH TRAILS!',140,12,w-355,27,align='center',maxlines=1)
  s.arena(132,62,w-148,h-159)
  s.button('PLAY',160,h-91,w-205,58,'orange','Play',size=30)
  for i,lab in enumerate(['CUSTOMIZE','SHOP','PROFILE','SETTINGS']):s.button(lab,8,102+i*61,116,54,action=lab,size=15)
 else:
  # Fixed Play/navigation. No page scroll; decoration yields at short heights.
  y=124;short=h<650;arenaH=126 if short else min(320,h-430)
  s.text('BATTLE WITH TRAILS!',12,y,w-24,26 if short else 30,align='center',maxlines=1)
  s.arena(8,y+48,w-16,arenaH)
  playY=y+48+arenaH+10
  s.button('PLAY',24,playY,w-48,64,'orange','Play',size=34)
  ny=playY+76;gap=8;bw=(w-32-gap)/2
  for i,lab in enumerate(['CUSTOMIZE','SHOP','PROFILE','SETTINGS']):s.button(lab,16+(i%2)*(bw+gap),ny+(i//2)*64,bw,56,action=lab,size=17 if short else 19)
  s.text('Steer. Trap. Survive.',16,ny+132,w-32,16,align='center')
 s.export('One-screen game menu with a single primary Play action.',['ready','profile-loading','offline-read-only','input-changed'],'Remove optional summary/decorative area before text or actions. No page scroll in any mode.')

def collection(w=1672,h=941,shop=False,slug=None):
 slug=slug or ('07-shop-desktop' if shop else '05-customize-desktop')
 title='COSMETIC SHOP' if shop else 'MAKE IT YOURS'
 s=Screen(slug,title,w,h,active='SHOP' if shop else 'CUSTOMIZE');x,y,mw,mh=s.shell()
 plateW=min(mw,680) if w>=1100 else mw
 s.skin('pill_cream',x,y-7,plateW,84 if w>=1100 else 56,1)
 fs=44 if w>=1100 else 28;first='COSMETIC' if shop else 'MAKE IT';last='SHOP' if shop else 'YOURS'
 fw=fm(fs).getlength(first);total=fw+fm(fs).getlength(last)+14;tx=x+(plateW-total)/2
 s.text(first,tx,y+4,fw+2,fs,maxlines=1);s.text(last,tx+fw+14,y+4,fm(fs).getlength(last)+3,fs,P['coral'] if shop else '#C24D06',maxlines=1)
 if w>=1100:
  gy=y+92;catalogW=mw*.51;gap=18;cw=(catalogW-gap)/2;ch=245
  for j,lab in enumerate(['ALL','CORES','TRAILS']):s.button(lab,x+j*(catalogW/3+2),gy,catalogW/3-5,58,selected=j==0,action='Filter'+lab,size=22)
  for i in range(4):s.item(i,x+(i%2)*(cw+gap),gy+78+(i//2)*(ch+16),cw,ch,i==1,owned=None)
  px=x+catalogW+24;pw=mw-catalogW-24
  s.arena(px,gy,pw,390)
  s.text('RING CORE',px,gy+407,pw,33,align='center')
  s.text('Cosmetic only. Same collision boundary.',px+10,gy+454,pw-20,19,body=True,align='center')
  s.button('VIEW ITEM',px+25,gy+505,pw-50,80,'orange','ItemDetails',size=35)
  s.text('Real-money purchases unavailable',px,gy+602,pw,18,body=True,align='center')
 else:
  gy=y+58
  for j,lab in enumerate(['ALL','CORES','TRAILS']):s.button(lab,x+j*(mw/3+2),gy,mw/3-4,50,selected=j==0,action='Filter'+lab,size=16)
  gap=10;cw=(mw-gap)/2;ch=190
  for i in range(4):s.item(i,x+(i%2)*(cw+gap),gy+66+(i//2)*(ch+12),cw,ch,i==1)
  dock=h-151;s.rect(0,dock-8,w,160,P['cream'],24)
  s.text('Ring core · 150 coins',x,dock,mw,21,align='center')
  s.button('VIEW ITEM',x,dock+36,mw,60,'orange','ItemDetails',size=25)
  s.text('Cosmetic only · no live purchases',x,dock+104,mw,15,body=True,align='center')
 s.export('Select a real catalog cosmetic; inspect before equipping or buying.',['owned','locked','equipped','affordable','insufficient','empty','loading','unavailable'],'Portrait replaces the large always-visible preview with an item sheet. The grid alone may scroll; tabs and action dock are fixed.')

def detail(w=1672,h=941,slug='06-item-details-desktop',insufficient=False):
 s=Screen(slug,'Item details',w,h,active='CUSTOMIZE');s.shell('YOUR COLLECTION',balance='80 COINS' if insufficient else '480 COINS')
 # Parent context remains beneath one modal scrim.
 s.rect(0,0,w,h,'#25172C',0);s.parts[-1]=s.parts[-1].replace('fill="#25172C"','fill="#25172C" opacity=".38"')
 dw=min(740,w-24);dh=660 if w>700 else min(704,h-28);x=(w-dw)/2;y=(h-dh)/2
 s.skin('pill_cream',x,y,dw,dh,.85)
 s.text('RING CORE',x+26,y+23,dw-100,40 if w>700 else 28)
 s.button('×',x+dw-78,y+15,60,58,action='CloseDetails',size=30)
 artH=260 if w>700 else 200;s.arena(x+26,y+93,dw-52,artH)
 s.text('Same speed. Same collision boundary.',x+26,y+artH+113,dw-52,22 if w>700 else 18,body=True,align='center')
 s.pill('150 COINS',x+dw/2-100,y+artH+157,200,58,size=25)
 s.text('You need 150 coins. Your balance is 80.' if insufficient else 'Your balance: 480 coins',x+26,y+artH+226,dw-52,20,body=True,align='center')
 s.button('NOT ENOUGH COINS' if insufficient else 'UNLOCK WITH COINS',x+24,y+dh-102,dw-48,72,'orange','Unlock',disabled=insufficient,size=28 if w>700 else 22)
 s.export('Honest cosmetic inspection with its source collection preserved.',['owned/equip','equipped','locked','insufficient','saving','failed','unavailable'],'Phone uses a safe-area sheet with pinned Close and action row; long description scrolls inside only.')

def purchase(kind='confirm',w=1672,h=941,slug=None):
 slug=slug or {'confirm':'08-purchase-confirm','pending':'09-purchase-processing','unknown':'10-purchase-reconcile'}[kind]
 s=Screen(slug,'Purchase '+kind,w,h,active='SHOP');s.shell('COSMETIC SHOP')
 s.rect(0,0,w,h,'#2A1732');s.parts[-1]=s.parts[-1].replace('fill="#2A1732"','fill="#2A1732" opacity=".40"')
 dw=min(640,w-24);dh=480 if kind=='confirm' else 430;x=(w-dw)/2;y=(h-dh)/2
 s.skin('pill_cream',x,y,dw,dh,.85)
 s.image('ring',x+dw/2-55,y+15,110,110,True)
 title={'confirm':'UNLOCK RING CORE?','pending':'UNLOCKING…','unknown':'CHECKING YOUR PURCHASE'}[kind]
 s.text(title,x+24,y+136,dw-48,32 if w>700 else 25,align='center',maxlines=2)
 copy={'confirm':'Spend 150 coins?\nBalance after confirmation: 330 coins.','pending':'Waiting for confirmation.\nYour purchase has not been confirmed yet.','unknown':'The outcome is not confirmed yet.\nCheck before trying another purchase.'}[kind]
 s.text(copy,x+28,y+215,dw-56,22 if w>700 else 19,body=True,align='center',maxlines=3)
 if kind=='confirm':
  gap=12;bw=(dw-60-gap)/2;s.button('CANCEL',x+30,y+dh-105,bw,70,action='CancelPurchase',size=23 if w>700 else 18);s.button('CONFIRM',x+30+bw+gap,y+dh-105,bw,70,'orange','ConfirmPurchase',size=23 if w>700 else 18)
 else:s.button('CHECK STATUS' if kind=='unknown' else 'PLEASE WAIT',x+30,y+dh-100,dw-60,68,'orange','Reconcile',disabled=kind=='pending',size=25 if w>700 else 20)
 s.export('Purchase status without duplicate charges or false refunds.',['confirm','cancel-before-submit','submitting','business-rejection','unknown','reconciling','owned-confirmed'],'Short phone copy, pinned buttons, controller focus starts on Cancel. Closing presentation cannot cancel an already-submitted write.')

def controls():
 s=Screen('02-controls-desktop','Controls');x,y,w,h=s.shell('TWO DIRECTIONS. ONE SURVIVOR.')
 s.arena(x+70,y+92,w-140,360)
 s.text('MOVE FORWARD AUTOMATICALLY',x,y+478,w,30,align='center')
 s.text('Hold left or right to steer. Avoid every trail and the edge.',x+25,y+528,w-50,25,body=True,align='center')
 s.button('A / ←   LEFT',x+150,y+585,350,66,action='TryLeft',size=27);s.button('D / →   RIGHT',x+w-500,y+585,350,66,action='TryRight',size=27)
 s.button('READY TO PLAY',x+w*.22,y+672,w*.56,76,'orange','Continue',size=34)
 s.export('Brief playable input explanation, no quiz or forced purchase.',['keyboard','touch','controller','input-switch','focus-lost'],'Same rules, hardware-specific controls. Review from Settings. Local intent demonstration only.')

def queue(w=1672,h=941,slug='03-queue-desktop',countdown=False):
 s=Screen(slug,'Countdown' if countdown else 'Quick Play queue',w,h);x,y,mw,mh=s.shell()
 if w>700:
  s.panel(x+130,y+40,mw-260,mh-125)
  s.text('GET READY' if countdown else 'FINDING YOUR ROUND',x+160,y+75,mw-320,46,P['cream'],align='center')
  s.image('ring',x+mw/2-80,y+195,160,160,True)
  s.text('3' if countdown else 'QUICK PLAY',x+170,y+392,mw-340,72 if countdown else 32,P['cream'],align='center')
  s.text('Mock match · no active multiplayer service',x+170,y+485,mw-340,22,P['cream'],body=True,align='center')
  if not countdown:s.button('CANCEL',x+mw*.3,y+585,mw*.4,76,action='CancelQueue',size=30)
 else:
  s.panel(12,185,w-24,420);s.text('FINDING YOUR ROUND',30,220,w-60,28,P['cream'],align='center',maxlines=2)
  s.image('ring',w/2-60,340,120,120,True);s.text('QUICK PLAY',20,494,w-40,28,P['cream'],align='center');s.text('MOCK MATCH',20,540,w-40,18,P['cream'],align='center')
  s.button('CANCEL',24,h-122,w-48,64,action='CancelQueue',size=25)
 s.export('One queue, no unnecessary mode selector or Ready page.',['entering','searching','cancel-requested','canceled','join-confirmed','join-failed','service-unavailable'],'Cancel stays visible. Animation never delays cancellation. Countdown is an authoritative/mocked event, not a local matchmaking simulation.')

def profile(w=1672,h=941,slug='11-profile-desktop',empty=False):
 s=Screen(slug,'Profile',w,h,active='PROFILE');x,y,mw,mh=s.shell('YOUR SIGNATURE',balance='0 COINS' if empty else '480 COINS')
 if w>700:
  s.arena(x+10,y+95,mw*.43,440);sx=x+mw*.48;sw=mw*.50
  s.text('TRAIL PLAYER',sx,y+102,sw,42);s.text('SAMPLE PROFILE',sx,y+166,sw,18,body=True)
  for i,(value,label) in enumerate([('0' if empty else '3','WINS'),('0' if empty else '12','ROUNDS'),('0' if empty else '120','TOTAL XP')]):
   yy=y+220+i*115;s.panel(sx,yy,sw,102);s.text(value,sx+24,yy+8,sw*.35,48,P['cream']);s.text(label,sx+sw*.40,yy+34,sw*.55,24,P['cream'])
  s.button('CUSTOMIZE',x+mw*.18,y+620,mw*.64,84,'orange','Customize',size=35)
 else:
  s.text('TRAIL PLAYER',x,y+62,mw,27,align='center');s.text('SAMPLE PROFILE',x,y+105,mw,14,body=True,align='center');s.image('ring',w/2-56,y+140,112,112,True)
  for i,(value,label) in enumerate([('3','WINS'),('12','ROUNDS'),('120','TOTAL XP')]):
   yy=y+275+i*84;s.panel(x,yy,mw,74);s.text(value,x+20,yy+6,mw*.3,34,P['cream']);s.text(label,x+mw*.38,yy+24,mw*.57,20,P['cream'])
  s.button('CUSTOMIZE',x,h-120,mw,64,'orange','Customize',size=26)
 s.export('Only supported profile totals, without invented levels or ranks.',['confirmed','zero-history','loading','stale','missing','long-name'],'Identity remains readable. Optional later history is separate content, not a longer Home.')

def settings(w=1672,h=941,slug='12-settings-desktop',large=False):
 s=Screen(slug,'Settings',w,h,active='SETTINGS');x,y,mw,mh=s.shell('SETTINGS')
 if w>700:
  for i,lab in enumerate(['AUDIO','CONTROLS','READABILITY']):s.button(lab,x+i*(mw/3+2),y+85,mw/3-8,66,selected=i==2,action='SettingsTab'+lab,size=25)
  rows=[('Music volume','50%'),('Sound volume','70%'),('Reduced motion','ON'),('Text size','150%' if large else '100%')]
  for i,(lab,value) in enumerate(rows):
   yy=y+186+i*115;s.skin('pill_cream',x+30,yy,mw-60,100,.8);s.text(lab,x+62,yy+24,mw*.55,30);s.pill(value,x+mw-275,yy+16,200,64,lab=='Reduced motion',26)
  s.text('Changes saved',x,y+660,mw,21,body=True,align='center')
 else:
  for i,lab in enumerate(['AUDIO','CONTROLS','TEXT']):s.button(lab,x+i*(mw/3+2),y+55,mw/3-4,54,selected=i==2,action='SettingsTab'+lab,size=16)
  f=31.5 if large else 21
  rows=[('Music','50%'),('Sound','70%'),('Reduced motion','ON'),('Text size','150%' if large else '100%')]
  for i,(lab,value) in enumerate(rows):
   yy=y+132+i*112;s.skin('pill_cream',x,yy,mw,98,.8);s.text(lab,x+18,yy+10,mw-36,f,maxlines=1);s.pill(value,x+mw-140,yy+49,124,44,lab=='Reduced motion',28.5 if large else 19)
  s.text('Changes saved',x,h-110,mw,18,body=True,align='center')
 s.export('Real audio/readability preferences with clear save state.',['draft','saving','saved','failed','offline','partial-default-reset'],'Category tabs and Back fixed; only settings rows may scroll. 150% text version allocates taller rows rather than scaling down the full screen.')

def hud(w=1672,h=941,slug='13-hud-desktop',spectator=False,eliminated=False):
 title='Spectator' if spectator else 'Eliminated' if eliminated else 'Match HUD'
 s=Screen(slug,title,w,h,kind='match',note='DESIGN PROPOSAL · MOCK MATCH')
 s.rect(0,0,w,h,P['well']);s.arena(5,40,w-10,h-95,hud=True,muted=eliminated)
 fs=23 if w>1000 else 18
 s.pill('2 REMAIN' if spectator else '4 REMAIN',14,7,180 if w>1000 else 140,49,False,fs)
 s.pill('TIME —:—',w-200,7,184,49,False,fs)
 if eliminated:
  s.skin('button_orange',w*.25,h*.30,w*.5,110,.55);s.text('OUT THIS ROUND',w*.25+15,h*.30+13,w*.5-30,46 if w>1000 else 28,P['cream'],align='center',outline=True)
  s.text('Placement is awaiting confirmation',w*.2,h*.30+130,w*.6,24 if w>1000 else 18,P['cream'],body=True,align='center')
 elif spectator:
  s.pill('SPECTATING · PLAYER 2' if w>1000 else 'PLAYER 2',w*.32,60,w*.36,54,True,22 if w>1000 else 18)
  s.button('LEAVE ROUND',w/2-130,h-90,260,60,action='LeaveRound',size=23)
 else:
  if w<1000:
   for label,x in [('‹',16),('›',w-80)]:s.button(label,x,h-86,64,64,action='Steer'+label,size=38)
  else:s.text('A / ←   LEFT      RIGHT   D / →',w/2-300,h-48,600,20,P['cream'],align='center')
 s.export('Keep trails and cores dominant, with two steering directions only.',['active','remaining-known/unknown','elapsed-known/unknown','round-ending','eliminated','spectating','disconnect'],'No shop/menu rail. Touch controls use bottom-corner 64px targets, to be verified against actual playfield sightlines. Time is elapsed, no new hard round limit. Spectator cycling deferred.')

def results(w=1672,h=941,slug='16-victory-desktop',victory=True,rewards=False):
 s=Screen(slug,'Rewards pending' if rewards else 'Victory' if victory else 'Defeat',w,h,kind='outcome',note='DESIGN PROPOSAL · MOCK OUTCOME')
 if w>700:
  s.logo(24,16,220);s.panel(w*.18,105,w*.64,h-232)
  s.text('CHECKING REWARDS' if rewards else 'LAST CORE STANDING' if victory else 'NEXT ROUND. NEW CHANCE.',w*.2,145,w*.6,54,P['cream'],align='center')
  s.image('ring',w/2-112,270,224,224,True)
  s.text('Awaiting confirmation' if rewards else 'YOU WIN' if victory else 'ROUND COMPLETE',w*.2,520,w*.6,42,P['cream'],align='center')
  s.text('Coins —     XP —' if rewards else 'Rewards will appear after confirmation.',w*.25,596,w*.5,26,P['cream'],body=True,align='center')
  s.button('HOME',w*.24,h-132,w*.23,84,action='Home',size=32);s.button('PLAY AGAIN',w*.51,h-132,w*.25,84,'orange','Rematch',size=32)
 else:
  s.logo(w/2-78,8,156);s.panel(8,146,w-16,h-283)
  s.text('YOU WIN' if victory else 'ROUND COMPLETE',24,188,w-48,34,P['cream'],align='center')
  s.image('ring',w/2-78,310,156,156,True)
  s.text('Rewards pending confirmation',26,520,w-52,21,P['cream'],body=True,align='center')
  s.button('PLAY AGAIN',20,h-145,w-40,64,'orange','Rematch',size=27);s.button('HOME',20,h-74,w-40,50,action='Home',size=21)
 s.export('Distinct victory/defeat mood with the same obvious next actions.',['victory','defeat','placement-unknown','settlement-pending','confirmed','refresh-failed'],'No invented payout, level or win streak. Confirmation can arrive after returning Home; transaction/state controller outlives presentation.')

def recovery(loading=False,slug=None):
 slug=slug or ('19-loading-desktop' if loading else '20-error-recovery-desktop')
 s=Screen(slug,'Loading' if loading else 'Profile recovery',active='');s.logo(s.w/2-160,55,320)
 x,y,w,h=460,310,752,475;s.skin('pill_cream',x,y,w,h,.8)
 s.text('PREPARING YOUR TRAIL…' if loading else 'LET’S GET YOU CONNECTED',x+32,y+36,w-64,40,align='center')
 s.text('Loading your profile. Your balance will appear when it is ready.' if loading else 'Your profile could not be confirmed.\nNothing has been reset or spent.',x+52,y+155,w-104,27,body=True,align='center')
 if loading:s.pill('PLEASE WAIT',x+220,y+295,312,64,True,26)
 else:s.button('TRY AGAIN',x+170,y+288,w-340,84,'orange','Retry',size=34);s.text('You can review controls while disconnected.',x+40,y+395,w-80,21,body=True,align='center')
 s.export('Honest profile status and recovery without invented data.',['loading','failed','leased','unsupported-schema','offline','retrying','service-unavailable'],'No arbitrary countdown or percentage. Decorative asset loading cannot block readable recovery controls indefinitely.')

def leave():
 s=Screen('21-leave-confirm','Leave confirmation',kind='dialog');s.arena(0,0,s.w,s.h,hud=True,muted=True)
 s.rect(0,0,s.w,s.h,'#25172C');s.parts[-1]=s.parts[-1].replace('fill="#25172C"','fill="#25172C" opacity=".38"')
 x,y,w,h=490,245,692,440;s.skin('pill_cream',x,y,w,h,.8)
 s.text('LEAVE THIS ROUND?',x+30,y+30,w-60,42,align='center')
 s.text('The round keeps running while this menu is open.',x+45,y+145,w-90,27,body=True,align='center')
 s.button('STAY',x+30,y+298,300,84,'orange','Stay',size=31);s.button('LEAVE',x+360,y+298,300,84,action='Leave',size=31)
 s.export('A safe leave choice without falsely pausing multiplayer.',['open','stay-focused','leaving','leave-failed'],'Stay receives initial focus. Back cancels the dialog and clears held steering intent.')

def mobile_recovery(loading=False):
 s=Screen('m12-loading-390' if loading else 'm13-recovery-390','Loading' if loading else 'Recovery',390,844,note='DESIGN PROPOSAL · NO PROFILE DATA')
 s.logo(90,22,210);s.skin('pill_cream',12,215,366,450,.8)
 s.text('PREPARING YOUR TRAIL…' if loading else 'LET’S RECONNECT',36,250,318,29,align='center',maxlines=2)
 s.text('Your balance will appear when your profile is ready.' if loading else 'Your profile could not be confirmed. Nothing has been reset.',36,365,318,22,body=True,align='center',maxlines=4)
 s.button('PLEASE WAIT' if loading else 'TRY AGAIN',28,550,334,68,'orange','Retry',disabled=loading,size=26)
 if not loading:s.button('REVIEW CONTROLS',28,715,334,60,action='Controls',size=23)
 s.export('Readable recovery on a narrow screen without fabricated counters.',['loading','failed','retrying','unavailable'],'No balance, ownership or fake progress percentage. Retry stays inside the safe action area.')

def mobile_controls():
 s=Screen('m14-controls-390','Controls',390,844);x,y,mw,mh=s.shell('HOW TO STEER')
 s.arena(8,218,374,260);s.text('Forward is automatic.',16,500,358,24,align='center')
 s.text('Hold left or right. Avoid every trail and the edge.',24,545,342,22,body=True,align='center')
 s.button('‹ LEFT',16,630,175,64,action='TryLeft',size=25);s.button('RIGHT ›',199,630,175,64,action='TryRight',size=25)
 s.button('READY TO PLAY',24,729,342,64,'orange','Continue',size=27)
 s.export('Two touch steering examples and a clear Continue action.',['touch','input-switch','focus-loss'],'No joystick, ability buttons or gameplay implementation.')

def compact_leave():
 s=Screen('c03-leave-568-landscape','Leave confirmation · compact',568,320,kind='dialog');s.arena(0,0,568,320,hud=True,muted=True)
 s.rect(0,0,568,320,'#25172C');s.parts[-1]=s.parts[-1].replace('fill="#25172C"','fill="#25172C" opacity=".36"')
 s.skin('pill_cream',32,24,504,272,.75);s.text('LEAVE THIS ROUND?',58,50,452,28,align='center')
 s.text('The round keeps running.',58,116,452,21,body=True,align='center')
 s.button('STAY',52,200,220,64,'orange','Stay',size=26);s.button('LEAVE',296,200,220,64,action='Leave',size=26)
 s.export('Short-landscape dialog preserves both 64px actions.',['stay-focused','leave','cancel'],'No desktop dialog uniformly shrunk into a short screen.')

def boards():
 s=Screen('00-design-system','Design system',1672,1080,kind='board',note='DESIGN PROPOSAL · TOKENS / COMPONENTS')
 s.logo(28,20,250);s.text('ONE PLAYFUL MATERIAL LANGUAGE',330,55,1260,52)
 for i,(name,color) in enumerate(P.items()):
  x=34+i*230;s.rect(x,238,205,90,color,24);s.text(name.upper(),x,340,205,20,align='center');s.text(color,x,374,205,18,body=True,align='center')
 s.text('TACTILE CONTROLS',32,452,1500,31)
 for i,(lab,var,sel,dis) in enumerate([('PLAY','orange',False,False),('BACK','plum',False,False),('SELECTED','plum',True,False),('UNAVAILABLE','plum',False,True)]):s.button(lab,32+i*405,510,380,94,var,selected=sel,disabled=dis,size=30)
 s.text('Fredoka One',32,660,680,56);s.text('Readable body text. No tiny text to rescue a broken layout.',32,742,740,28,body=True)
 s.text('Home stays on one screen.\nPlay remains the strongest action.\nInventory scrolls inside its panel.',900,666,690,28,body=True)
 s.text('48px minimum practical targets · purposeful motion · no live commerce',32,936,1600,25,align='center')
 s.export('Color/type/depth consistency, not a new visual direction.',['button variants','type','palette','component hierarchy'],'Native text and controls sit on reusable material skins.')
 s=Screen('00-component-states','Component states',1672,1080,kind='board',note='DESIGN PROPOSAL · COMPONENT STATES')
 s.text('EVERY STATE TELLS THE TRUTH',40,28,1592,48)
 for i,lab in enumerate(['DEFAULT','HOVER','FOCUSED','PRESSED','SELECTED','DISABLED','LOADING…']):
  col,row=i%4,i//4;x=34+col*408;y=130+row*125
  s.button(lab,x,y+(3 if lab=='PRESSED' else 0),380,94,'orange' if lab=='PRESSED' else 'plum',selected=lab in ['FOCUSED','SELECTED'],disabled=lab=='DISABLED',size=25)
 s.text('ITEM STATES',35,430,1500,32)
 for i in range(4):s.item(i,34+i*408,495,380,300,i==1)
 s.text('Owned is not equipped. Pending is not purchased. Unknown is not failed.',35,870,1600,30,align='center')
 s.text('Every appearance has a matching semantic state, focus rule and cancellation policy.',35,930,1600,24,body=True,align='center')
 s.export('Shared controls across all screens, including unavailable and pending.',['normal','hover','focus','press','selected','disabled','loading','owned','locked','equipped'],'Focused and selected are distinct contracts; final focus uses a dual cream/plum outline, not color alone.')
 s=Screen('00-motion-storyboard','Motion storyboard',1672,941,kind='board',note='DESIGN PROPOSAL · TIMINGS ARE HYPOTHESES')
 s.text('PRESS WITH PURPOSE',40,45,1592,55)
 for i,(lab,time) in enumerate([('REST','0 ms'),('DEPRESS','0–45 ms'),('RELEASE','45–155 ms'),('CONFIRMED','160 ms')]):
  x=34+i*409;s.text(lab,x,260,375,28,align='center');s.button('EQUIP',x,350+(5 if i==1 else 0),375,112,'orange' if i==1 else 'plum',selected=i==3,size=36);s.text(time,x,510,375,25,body=True,align='center')
 s.text('Short response. Small travel. Cancelable motion. Clear confirmation.',40,667,1592,30,align='center')
 s.text('Reduced motion: static focus + pressed tint + immediate state change. Sound off remains fully understandable.',100,748,1472,25,body=True,align='center')
 s.export('A storyboard of intended feel, not an implemented animation.',['rest','press','release','confirmed'],'No whole-screen bounce, loops or animation-gated input.')

if __name__=='__main__':
 boards();home();controls();queue();queue(slug='04-countdown-desktop',countdown=True);collection();detail();collection(shop=True)
 for k in ['confirm','pending','unknown']:purchase(k)
 profile();settings();hud();hud(slug='14-elimination-desktop',eliminated=True);hud(slug='15-spectator-desktop',spectator=True)
 results();results(slug='17-defeat-desktop',victory=False);results(slug='18-rewards-pending-desktop',rewards=True)
 recovery(True);recovery();leave();detail(slug='22-insufficient-funds',insufficient=True)
 home(390,844,'m01-home-390');home(320,568,'m02-home-320');home(844,390,'c01-home-844-landscape');home(2560,1080,'u01-home-ultrawide')
 collection(390,844,slug='m03-customize-390');collection(390,844,True,'m04-shop-390');detail(390,844,'m05-item-details-390');purchase('confirm',390,844,'m06-purchase-390')
 profile(390,844,'m07-profile-390');settings(390,844,'m08-settings-390');settings(390,844,'m09-settings-150',True);queue(390,844,'m10-queue-390');hud(844,390,'c02-hud-844-landscape');results(390,844,'m11-victory-390')
 mobile_recovery(True);mobile_recovery(False);mobile_controls();compact_leave();collection(768,1024,slug='t01-customize-768');hud(390,844,'m15-spectator-390',spectator=True);profile(slug='23-profile-empty',empty=True)
 (PLAN/'mockup-manifest.json').write_text(json.dumps(PAGES,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
 print(json.dumps({'screens':len(PAGES),'warnings':[{p['slug']:p['warnings']} for p in PAGES if p['warnings']]}))
