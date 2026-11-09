"""Fresh design-only screen family. No production Luau or Studio writes.
Reuses the audited screen content/state inventory, not the rejected skin system.
All surfaces, paths, tokens and controls are editable geometry; only the newly
generated wordmark is a raster art layer. There are no stretched panel textures.
"""
from pathlib import Path
import math,json,base64
ROOT=Path(__file__).resolve().parents[3]
PLAN=ROOT/'design/ui-fresh-direction';OUT=PLAN/'mockups';OUT.mkdir(exist_ok=True)
old=ROOT/'design/ui-master-plan/source/build_mockups.py'
ns={'__file__':str(old),'__name__':'design_content_library'}
exec(compile(old.read_text(encoding='utf-8'),str(old),'exec'),ns)
Old=ns['Screen'];P={'peach':'#DFF4E8','cream':'#FFFCF3','plum':'#192A46','well':'#FFFCF3','orange':'#FF6957','teal':'#5877E8','coral':'#D33D30'}
ns.update(PLAN=PLAN,OUT=OUT,P=P,PAGES=[])

class Fresh(Old):
 def __init__(self,slug,title,w=1672,h=941,active='',kind='menu',note='DESIGN PROPOSAL · SAMPLE DATA'):
  self.slug,self.title,self.w,self.h,self.active,self.kind=slug,title,w,h,active,kind
  self.parts=[];self.boxes=[];self.actions=[];self.warnings=[]
  self.parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><title>{title} — new Trail Wars design proposal</title><defs><filter id="soft"><feDropShadow dx="0" dy="4" stdDeviation="0" flood-color="#192A46"/></filter><clipPath id="ringclip"><ellipse cx="78.5" cy="73" rx="76" ry="71"/></clipPath></defs>')
  font=(PLAN/'source/fonts/FredokaOne-Regular.ttf').read_bytes();self.parts.append('<style>@font-face{font-family:"Fredoka One";src:url(data:font/ttf;base64,'+base64.b64encode(font).decode()+')}</style>')
  self.rect(0,0,w,h,P['cream'])
  self.parts.append(f'<path d="M0 0 H{w*.52} Q{w*.39} {h*.10} 0 {h*.43}Z" fill="{P["peach"]}"/><path d="M0 {h*.85} Q{w*.18} {h*.78} {w*.45} {h*.88} T{w} {h*.83}V{h}H0Z" fill="{P["peach"]}"/>')
  self.text(note,14,h-15,w-28,13,body=True,align='center')
 def text(self,value,x,y,w,size=22,color=None,body=False,align='left',maxlines=4,key=None,outline=False):
  value={'PEACH':'MINT','CREAM':'WARM WHITE','PLUM':'NAVY INK','WELL':'PAPER','ORANGE':'CORAL ACTION','TEAL':'CORNFLOWER','CORAL':'ALERT RED'}.get(value,value)
  if color in [P['cream'],'#FFF1DA']:color=P['plum']
  return super().text(value,x,y,w,size,color,body,align,maxlines,key,False)
 def export(self,purpose,states,transform='',status='proposal'):
  purpose=purpose.replace('Color/type/depth consistency, not a new visual direction.','New mint, ink and coral visual system.')
  transform=transform.replace('Native text and controls sit on reusable material skins.','Native text and geometric controls; no stretched panel textures.').replace('dual cream/plum outline','dual paper/ink outline')
  return super().export(purpose,states,transform,status)
 def skin(self,key,x,y,w,h,scale=.55):
  fill=P['orange'] if key in ['button_orange','tab_orange'] else '#DEE6FF' if key=='card_selected' else P['peach'] if key in ['pill_teal','tab_teal'] else P['cream']
  radius=min(20,h*.23)
  self.rect(x,y+5,w,h-5,P['plum'],radius)
  self.rect(x,y,w,h-6,fill,radius,P['plum'],3)
 def image(self,key,x,y,w,h,clip=False):
  if key=='logo':self.parts.append(f'<image x="{x}" y="{y}" width="{w}" height="{h}" preserveAspectRatio="xMidYMid meet" xlink:href="../source/assets/wordmark.png"/>');return
  cx,cy=x+w/2,y+h/2;r=min(w,h)*.36
  if key in ['core','core_neutral','ring']:
   self.parts.append(f'<circle cx="{cx}" cy="{cy+4}" r="{r}" fill="#192A46" opacity=".2"/><circle cx="{cx}" cy="{cy}" r="{r}" fill="#FF6957" stroke="#192A46" stroke-width="3"/>')
   if key=='ring':self.parts.append(f'<circle cx="{cx}" cy="{cy}" r="{r*.59}" fill="#FFFCF3" stroke="#192A46" stroke-width="2"/>')
   return
  if key=='coin':self.parts.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#F4CE54" stroke="#192A46" stroke-width="2"/>');return
  if key.startswith('icon_'):
   self.rect(x+w*.18,y+h*.18,w*.64,h*.64,'none',7,P['plum'],3)
   if key=='icon_customize':self.parts.append(f'<circle cx="{cx}" cy="{cy}" r="{r*.45}" fill="#5877E8"/>')
   elif key=='icon_shop':self.parts.append(f'<path d="M{x+w*.12} {y+h*.3}H{x+w*.88}L{x+w*.75} {y+h*.75}H{x+w*.25}Z" fill="#FF6957" stroke="#192A46" stroke-width="2"/>')
   elif key=='icon_profile':self.parts.append(f'<circle cx="{cx}" cy="{cy-h*.14}" r="{r*.4}" fill="#192A46"/>')
   else:self.parts.append(f'<circle cx="{cx}" cy="{cy}" r="{r*.5}" fill="#5877E8" stroke="#192A46" stroke-width="2"/>')
   return
  # Trail swatches are geometry with stable stroke width, not resized textures.
  yy=y+h*.64;d=f'M{x+8} {yy} C{x+w*.28} {yy} {x+w*.26} {y+h*.2} {x+w*.5} {y+h*.38} S{x+w*.78} {y+h*.65} {x+w-8} {y+h*.32}'
  dash=' stroke-dasharray="15 10"' if key in ['dashed_icon','route_dashed'] else ''
  self.parts.append(f'<path d="{d}" fill="none" stroke="#5877E8" stroke-width="{max(5,min(12,h*.12))}" stroke-linecap="round"{dash}/>')
 def logo(self,x,y,w):self.image('logo',x,y,w,w*266/570)
 def button(self,label,x,y,w,h,variant='plum',action=None,selected=False,disabled=False,size=None):
  self.parts.append('<g'+(' opacity=".45"' if disabled else '')+'>');self.skin('button_orange' if variant=='orange' else 'card_selected' if selected else 'button_plum',x,y,w,h)
  fs=size or (26 if self.w>700 else 20)
  self.text(label,x+14,y+(h-fs*1.22)/2-4,w-28,fs,align='center',maxlines=2)
  self.parts.append('</g>')
  if action:self.actions.append({'id':action,'rect':[x,y,w,h],'label':label,'disabled':disabled})
 def pill(self,label,x,y,w=150,h=52,teal=False,size=22):
  self.rect(x,y,w,h,P['peach'] if teal else '#F9D96D',min(16,h*.3),P['plum'],2)
  self.text(label,x+9,y+(h-size*1.2)/2-2,w-18,size,align='center',maxlines=2)
 def arena(self,x,y,w,h,hud=False,muted=False,open=False):
  if not open:self.rect(x,y,w,h,P['cream'],20,P['plum'],3)
  ox,oy=x+w*.055,y+h*.075;iw,ih=w*.87,h*.79
  routes=[('#5877E8',[(0,.30),(.12,.30),(.18,.08),(.32,.08),(.42,.08)]),('#FF6957',[(.03,.94),(.12,.72),(.25,.82),(.34,.46),(.88,.46)]),('#F4CE54',[(.24,.94),(.33,.94),(.42,.65),(.64,.77),(.88,.80)])]
  for i,(col,a) in enumerate(routes):
   p=[(ox+u*iw,oy+v*ih) for u,v in a];d=f'M{p[0][0]} {p[0][1]} C{p[1][0]} {p[1][1]} {p[2][0]} {p[2][1]} {p[3][0]} {p[3][1]} S{p[4][0]-iw*.15} {p[4][1]} {p[4][0]} {p[4][1]}'
   thick=max(5,min(22,w*.018)) if open else max(4,min(10,w*.012));alpha=.48 if muted else 1
   self.parts.append(f'<path d="{d}" fill="none" stroke="#192A46" stroke-width="{thick+3}" stroke-linecap="round" opacity="{alpha}"/><path d="{d}" fill="none" stroke="{col}" stroke-width="{thick}" stroke-linecap="round" opacity="{alpha}"/>')
   cx,cy=p[4];r=max(11,min(24,w*.028));self.parts.append(f'<circle cx="{cx+r}" cy="{cy}" r="{r}" fill="#FFFCF3" stroke="#192A46" stroke-width="3"/><circle cx="{cx+r}" cy="{cy}" r="{r*.72}" fill="{col}"/>')
   if i==1 and not muted:self.pill('YOU',cx+r-34,cy-r-39,68,32,True,16)
 def item(self,index,x,y,w,h,selected=False,owned=None):
  name,key,price,state=ns['CAT'][index];self.skin('card_selected' if selected else 'card_plum',x,y,w,h)
  small=w<230;fs=17 if small else 24
  if small:
   self.text(name.upper(),x+12,y+12,w-24,fs,align='center',maxlines=2);self.image(key,x+w*.22,y+58,w*.56,65)
  else:
   self.text(name.upper(),x+18,y+19,w*.49,fs,maxlines=2);self.image(key,x+w*.56,y+42,w*.37,104)
  label='OWNED' if (owned if owned is not None else state=='OWNED') else str(price)+' COINS'
  self.pill(label,x+14,y+h-56,min(w-28,190),42,teal=label=='OWNED',size=16 if small else 20)
  if selected:self.pill('PREVIEW',x+w-104,y+10,92,28,True,13)
  self.actions.append({'id':'item-'+str(index),'rect':[x,y,w,h],'label':name,'disabled':False})

ns['Screen']=Fresh
def home(w=1672,h=941,slug='01-home-desktop'):
 s=Fresh(slug,'Home',w,h)
 if w>=1100:
  content=min(w-64,1840);left=(w-content)/2
  s.logo(left+8,22,430);s.pill('480 COINS',left+content-290,24,280,66,False,30)
  s.arena(left+content*.37,72,content*.63,h-252,open=True)
  py=h*.47;s.button('PLAY  ›',left+12,py,content*.31,146,'orange','Play',size=86)
  s.text('LAST CORE STANDING',left+12,py+170,content*.35,32,maxlines=1)
  gap=16;bw=(content-gap*3)/4
  for i,lab in enumerate(['CUSTOMIZE','SHOP','PROFILE','SETTINGS']):s.button(lab,left+i*(bw+gap),h-120,bw,82,action=lab,size=25)
 elif w>=600:
  s.logo(10,5,144);s.pill('480 COINS',w-190,10,180,44,size=18);s.text('LAST CORE STANDING',180,16,w-390,23,align='center',maxlines=1)
  s.arena(186,76,w-202,h-190,open=True);s.button('PLAY  ›',215,h-84,w-248,60,'orange','Play',size=32)
  for i,lab in enumerate(['CUSTOMIZE','SHOP','PROFILE','SETTINGS']):s.button(lab,10,98+i*60,152,52,action=lab,size=17)
 else:
  short=h<650;s.logo(8,8,min(190,w*.44));s.pill('480 COINS',w-155,18,147,46,size=16)
  ay=104 if short else 126;ah=150 if short else min(320,h-510)
  s.arena(8,ay,w-16,ah,open=True);ry=ay+ah+14
  s.text('LAST CORE STANDING',12,ry,w-24,22 if short else 26,align='center',maxlines=1)
  py=ry+42;s.button('PLAY  ›',20,py,w-40,64 if short else 84,'orange','Play',size=42 if short else 52)
  ny=max(py+(64 if short else 84)+18,h-166);bw=(w-34)/2;bh=56 if short else 64
  for i,lab in enumerate(['CUSTOMIZE','SHOP','PROFILE','SETTINGS']):s.button(lab,12+(i%2)*(bw+10),ny+(i//2)*(bh+8),bw,bh,action=lab,size=17 if short else 20)
 s.export('A new one-screen game menu, not stretched legacy artwork.',['ready','loading-profile','offline','input-changed'],'Distinct spacious, compact-landscape and portrait compositions. Play + four root destinations remain visible; no page scrolling.')

if __name__=='__main__':
 ns['boards']();home();ns['controls']();ns['queue']();ns['queue'](slug='04-countdown-desktop',countdown=True);ns['collection']();ns['detail']();ns['collection'](shop=True)
 for k in ['confirm','pending','unknown']:ns['purchase'](k)
 ns['profile']();ns['settings']();ns['hud']();ns['hud'](slug='14-elimination-desktop',eliminated=True);ns['hud'](slug='15-spectator-desktop',spectator=True)
 ns['results']();ns['results'](slug='17-defeat-desktop',victory=False);ns['results'](slug='18-rewards-pending-desktop',rewards=True);ns['recovery'](True);ns['recovery']();ns['leave']();ns['detail'](slug='22-insufficient-funds',insufficient=True)
 home(390,844,'m01-home-390');home(320,568,'m02-home-320');home(844,390,'c01-home-844-landscape');home(2560,1080,'u01-home-ultrawide')
 ns['collection'](390,844,slug='m03-customize-390');ns['collection'](390,844,True,'m04-shop-390');ns['detail'](390,844,'m05-item-details-390');ns['purchase']('confirm',390,844,'m06-purchase-390')
 ns['profile'](390,844,'m07-profile-390');ns['settings'](390,844,'m08-settings-390');ns['settings'](390,844,'m09-settings-150',True);ns['queue'](390,844,'m10-queue-390');ns['hud'](844,390,'c02-hud-844-landscape');ns['results'](390,844,'m11-victory-390')
 ns['mobile_recovery'](True);ns['mobile_recovery'](False);ns['mobile_controls']();ns['compact_leave']();ns['collection'](768,1024,slug='t01-customize-768');ns['hud'](390,844,'m15-spectator-390',spectator=True);ns['profile'](slug='23-profile-empty',empty=True)
 pages=ns['PAGES'];(PLAN/'mockup-manifest.json').write_text(json.dumps(pages,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
 print(json.dumps({'screens':len(pages),'warnings':[{p['slug']:p['warnings']} for p in pages if p['warnings']]}))
