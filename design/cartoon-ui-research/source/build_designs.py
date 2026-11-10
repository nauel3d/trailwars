"""Editable, original design proposals only. Does not import or write game source."""
from pathlib import Path
from html import escape
import json, math, base64
R=Path(__file__).resolve().parent.parent
for d in ['screen-designs','component-designs','motion-storyboards','concepts','exports','qa']:(R/d).mkdir(parents=True,exist_ok=True)
FONT=(R/'source/fonts/FredokaOne-Regular.ttf').read_bytes()
PALETTES={
 'A':dict(name='Candy Comet Arcade',paper='#FFF9E9',ink='#20334C',mint='#C8E9D9',coral='#F66B55',blue='#5579D9',yellow='#F3C653',shade='#C44B3E',field='#EDF5DE'),
 'B':dict(name='Stickerbook Showdown',paper='#F3E7CE',ink='#343A32',mint='#CAD6AD',coral='#D8523F',blue='#537DB0',yellow='#E7B348',shade='#8B4739',field='#F7F0DF'),
 'C':dict(name='Miniature Toy Arena',paper='#DCEAF0',ink='#243C54',mint='#9AD9C6',coral='#ED735C',blue='#5283C4',yellow='#F4C66B',shade='#AA4A42',field='#F6F2DE'),
}
MAN=[]
class Canvas:
 def __init__(self,w,h,k='A'):
  self.w,self.h,self.k=w,h,k;self.p=PALETTES[k];self.s=[]
  p=self.p
  if k=='B':
   self.s=[]
  self.s.append(f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><title>TRAIL WARS — {p["name"]} — original unimplemented proposal</title><defs><style>@font-face{{font-family:"Fredoka One";src:url(data:font/ttf;base64,{base64.b64encode(FONT).decode()})}}text{{font-family:"Fredoka One",Arial;fill:{p["ink"]}}}.body{{font-family:Arial}}.line{{stroke:{p["ink"]};stroke-linejoin:round;stroke-linecap:round}}</style><linearGradient id="body" x1="0" y1="0" x2=".2" y2="1"><stop stop-color="#FFFFFF" stop-opacity=".5"/><stop offset=".45" stop-color="#FFFFFF" stop-opacity="0"/><stop offset="1" stop-color="#20334C" stop-opacity=".18"/></linearGradient><linearGradient id="plastic" x2="0" y2="1"><stop stop-color="#FFFFFF"/><stop offset="1" stop-color="#CFDBDC"/></linearGradient><pattern id="dots" width="24" height="24" patternUnits="userSpaceOnUse"><circle cx="2" cy="2" r="1" fill="{p["ink"]}" opacity=".055"/></pattern></defs>')
  if k=='B':
   data=base64.b64encode((R/'source/fonts/Kalam-Bold.ttf').read_bytes()).decode()
   self.add('<style>@font-face{font-family:Kalam;src:url(data:font/ttf;base64,'+data+')}text{font-family:Kalam,Arial}.body{font-family:Arial}</style>')
  self.rect(0,0,w,h,p['paper']);self.rect(0,0,w,h,'url(#dots)')
 def add(self,s):self.s.append(s)
 def text(self,x,y,t,size=18,color=None,body=False,anchor=None,weight=None):
  self.add(f'<text x="{x}" y="{y}" font-size="{size}"'+(f' style="fill:{color}"' if color else '')+(f' class="body"' if body else '')+(f' text-anchor="{anchor}"' if anchor else '')+(f' font-weight="{weight}"' if weight else '')+'>'+escape(str(t))+'</text>')
 def rect(self,x,y,w,h,fill,r=0,stroke=None,sw=2):
  self.add(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>')
 def path(self,d,fill='none',stroke=None,sw=2,extra=''):
  self.add(f'<path d="{d}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"' if stroke else '')+f' {extra}/>')
 def circle(self,x,y,r,fill,stroke=None,sw=2):self.add(f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}"'+(f' stroke="{stroke}" stroke-width="{sw}"' if stroke else '')+'/>')
 def panel(self,x,y,w,h,kind='plain',fill=None):
  p=self.p;fill=fill or p['paper']
  if self.k=='B':
   d=f'M{x+8} {y} L{x+w-12} {y+3} L{x+w} {y+11} L{x+w-3} {y+h-9} L{x+w-13} {y+h} L{x+5} {y+h-3} L{x} {y+8}Z'
   self.path(d,fill,p['ink'],2)
   if kind!='plain':self.rect(x+w*.35,y-6,w*.3,16,p['yellow'],0)
  elif self.k=='C':
   self.rect(x,y+9,w,h,p['ink'],20);self.rect(x,y,w,h,'#B2BFB7',20,p['ink'],2);self.rect(x+5,y+5,w-10,h-13,fill,16,'#FFFFFF',2)
  else:
   if kind=='raised':self.rect(x+1,y+6,w,h,p['ink'],18)
   self.rect(x,y,w,h,fill,18,p['ink'],2)
 def button(self,x,y,w,h,label,primary=False,icon=None,selected=False,disabled=False,pressed=False):
  p=self.p;fill=p['coral'] if primary else p['yellow'] if selected else p['paper'];ink=p['ink']
  if disabled:fill='#DADBD1'
  depth=2 if pressed else 6
  if self.k=='B':
   self.path(f'M{x+4} {y+depth} L{x+w-8} {y+depth} L{x+w} {y+h+depth-8} L{x+w-5} {y+h+depth} L{x} {y+h+depth-3}Z',ink)
   self.path(f'M{x+4} {y} L{x+w-8} {y} L{x+w} {y+h-8} L{x+w-5} {y+h} L{x} {y+h-3}Z',fill,ink,2)
  else:
   r=h/2 if primary else 12
   self.rect(x,y+depth,w,h,ink,r);self.rect(x,y,w,h,fill,r,ink,2.5)
   if primary or self.k=='C':self.path(f'M{x+20} {y+8} H{x+w-25}',stroke='#FFFFFF',sw=2,extra='opacity=".5"')
  tx=x+(22 if primary else w/2);anchor=None if primary else 'middle'
  if label in ['◀','▶']:
   d=-1 if label=='◀' else 1;cx=x+w/2;cy=y+h/2
   self.path(f'M{cx-d*8} {cy-9} L{cx+d*8} {cy} L{cx-d*8} {cy+9}Z',ink)
  else:self.text(tx,y+h*.65,label, min(38,h*.37), '#FFFFFF' if primary and not disabled else ink,anchor=anchor)
  if primary and label in ['PLAY','PLAY AGAIN','INSPECT ITEM','PREVIEW ONLY','NEXT ROUND','MAIN ACTION'] and w>=180:self.path(f'M{x+w-37} {y+h*.32} l14 {h*.18} l-14 {h*.18}',stroke=p['paper'],sw=4)
 def vehicle(self,x,y,s=1,color=None,angle=0,expression='ready'):
  p=self.p;c=color or p['coral'];ink=p['ink'];self.add(f'<g transform="translate({x} {y}) rotate({angle}) scale({s})">')
  if self.k=='B':
   self.path('M-36 -27 L8 -34 Q40 -24 37 10 L19 32 L-33 26 L-44 1Z',p['paper'],p['paper'],9)
   self.path('M-36 -27 L8 -34 Q40 -24 37 10 L19 32 L-33 26 L-44 1Z',c,ink,2.5)
   self.path('M-35 -15 L-55 -22 L-51 -1 L-34 0',p['yellow'],ink,2)
   self.path('M-24 -24 L9 -28',stroke=p['paper'],sw=4)
   self.rect(-13,-19,37,36,ink,12)
  elif self.k=='C':
   self.add('<ellipse cx="-1" cy="29" rx="43" ry="10" fill="#243C54" opacity=".16"/>')
   self.rect(-43,-23,82,56,ink,26);self.rect(-43,-31,82,54,c,25,ink,2.5);self.rect(-43,-31,82,54,'url(#body)',25)
   self.path('M-34 -24 Q-9 -34 8 -23',stroke='#FFFFFF',sw=4)
   self.rect(-7,-24,34,38,ink,13)
   self.rect(-48,-12,12,32,p['yellow'],5,ink,2)
  else:
   self.add('<ellipse cx="-3" cy="28" rx="40" ry="8" fill="#20334C" opacity=".13"/>')
   self.path('M-26 -19 L-45 -32 L-53 -26 L-41 -1 M-26 13 L-46 27 L-53 20 L-39 -4',p['yellow'],ink,2)
   self.path('M-34 -25 Q-11 -43 19 -27 Q48 -8 33 18 Q16 42 -17 28 Q-44 18 -34 -25Z',c,ink,2.7)
   self.path('M-34 -25 Q-11 -43 19 -27 Q48 -8 33 18 Q16 42 -17 28 Q-44 18 -34 -25Z','url(#body)')
   self.path('M-23 -22 Q-15 -29 -4 -27',stroke='#FFF9E9',sw=5)
   self.path('M-24 20 Q-6 29 11 23',stroke='#FFFFFF',sw=4,extra='opacity=".35"')
   self.rect(-10,-21,36,38,ink,16)
  if expression=='out':
   for ex in [1,15]:self.path(f'M{ex-3} -9 l6 6 m-6 0 l6 -6',stroke=p['paper'],sw=2.5)
  else:
   self.rect(1,-13,5,11,p['paper'],2);self.rect(15,-13,5,11,p['paper'],2)
   if expression=='win':self.path('M2 4 Q10 11 19 3',stroke=p['paper'],sw=2)
  self.add('</g>')
 def rocket(self,x,y,s=1,angle=0,turret=False):
  p=self.p;self.add(f'<g transform="translate({x} {y}) rotate({angle}) scale({s})">')
  self.path('M-24 -5 L-38 -8 L-34 0 L-38 8 L-24 5',p['yellow'])
  self.path('M-15 -9 L-21 -20 L-8 -18 L2 -8 M-15 9 L-21 20 L-8 18 L2 8',p['blue'] if turret else p['coral'],p['ink'],2)
  self.rect(-25,-10,44,20,p['paper'],9,p['ink'],2);self.circle(18,0,10,p['yellow'] if turret else p['coral'],p['ink'],2)
  self.rect(-16,-7,6,14,p['blue'] if turret else p['coral'],2);self.circle(0,0,4,p['ink']);self.add('</g>')
 def trail(self,d,c,sw=10,decorative=False):
  self.path(d,stroke=self.p['ink'],sw=sw+2)
  self.path(d,stroke=c,sw=sw)
  if self.k!='B' and decorative:self.path(d,stroke='#FFFFFF',sw=sw*.22,extra='opacity=".4"')
 def wordmark(self,x,y,s=1):
  self.add(f'<g transform="translate({x} {y}) scale({s}) rotate(-4)">')
  self.text(0,0,'TRAIL',52);self.text(42,47,'WARS',52)
  self.trail('M-5 28 Q-18 70 58 65 Q116 65 167 45',self.p['coral'],7,True)
  self.circle(166,45,8,self.p['blue'],self.p['ink']);self.path('M-15 -30 l-7 -12 M-7 -38 l0 -10',stroke=self.p['yellow'],sw=5);self.add('</g>')
 def nav(self,active='HOME'):
  p=self.p
  if self.w<600:
   self.wordmark(23,59,.48);self.button(self.w-103,35,81,38,'HOME' if active!='HOME' else '480')
  else:
   self.wordmark(40,52,.6)
   for i,t in enumerate(['HOME','CUSTOMIZE','SHOP','PROFILE','SETTINGS']):
    x=245+i*153;self.text(x,53,t,16,color=p['coral'] if t==active else p['ink'])
    if t==active:self.path(f'M{x} 65 h54',stroke=p['coral'],sw=4)
   self.circle(self.w-128,45,12,p['yellow'],p['ink']);self.text(self.w-105,51,'480',18)
 def arena(self,x,y,w,h,game=True):
  p=self.p
  assert abs(w/h-1.625)<.01,'Authoritative arena ratio must stay 1300:800'
  if self.k=='C':self.panel(x-9,y-9,w+18,h+18,'raised',p['mint'])
  elif self.k=='B':self.panel(x-6,y-6,w+12,h+12,fill=p['paper'])
  else:self.rect(x-5,y-5,w+10,h+16,p['ink'],18)
  self.rect(x,y,w,h,p['field'],12,p['ink'],2)
  self.add(f'<g transform="translate({x} {y}) scale({w/1300})">')
  # Illustrative paths; not gameplay collision or authoritative simulation.
  paths=[('M70 640 H320 Q380 640 380 570 V340 Q380 280 450 280 H820',p['coral'],820,280,-10),('M90 100 H1000 Q1120 100 1120 210 V650 H880',p['blue'],880,650,180),('M560 740 H600 Q650 740 650 680 V490 Q650 430 720 430 H1000',p['yellow'],1000,430,-3),('M180 180 V320 Q180 380 240 380 H320', '#18978F',320,380,0)]
  for d,c,xx,yy,a in paths:
   self.trail(d,c,7,True);self.vehicle(xx,yy,.21,c,a)
  self.rect(760,205,120,45,p['ink'],10);self.text(820,237,'YOU',32,p['paper'],anchor='middle')
  if game:
   self.rocket(650,175,.40,25);self.rocket(440,610,.40,-35,True)
   self.circle(1030,428,26,'none',p['yellow'],3);self.path('M1030 380 v-18 M1060 397 l16 -12 M1067 433 h20',stroke=p['yellow'],sw=5)
  self.add('</g>')
 def finish(self,name,folder='screen-designs',label=None):
  self.text(self.w-12,self.h-9,'DESIGN PROPOSAL · SAMPLE DATA · NOT ROBLOX CAPTURE',9,body=True,anchor='end')
  self.add('</svg>');dest=R/folder/(name+'.svg');dest.write_text(''.join(self.s),encoding='utf-8')
  MAN.append(dict(id=name,file=str(dest.relative_to(R)).replace('\\','/'),width=self.w,height=self.h,concept=self.k,label=label or name))

def header(c,title,sub=None):
 p=c.p;mobile=c.w<600;c.nav(title.upper());c.text(22 if mobile else 50,126 if mobile else 130,title,30 if mobile else 40)
 if sub:c.text(23 if mobile else 52,151 if mobile else 157,sub,13 if mobile else 16,body=True)

def home(k,w=1280,h=720):
 c=Canvas(w,h,k);p=c.p;mobile=w<600;compact=h<500
 if mobile and h<650:
  c.path(f'M0 0 H{w} V185 Q100 230 0 207Z',p['mint']);c.nav();c.text(21,127,'Small racers.',25);c.text(21,160,'Big trouble.',30,p['coral'])
  c.trail('M-18 292 Q106 353 171 257 T303 256',p['coral'],13,True);c.vehicle(240,265,1.22,p['coral'],-13);c.vehicle(103,307,.57,p['blue'],-15)
  c.button(20,356,w-40,65,'PLAY',True);c.text(23,456,'Customize',17);c.text(w-23,456,'Shop',17,anchor='end');c.text(23,503,'Profile',17);c.text(w-23,503,'Settings',17,anchor='end');c.text(23,539,'3 rounds · Homing + Jump',11,body=True)
 elif mobile:
  c.path(f'M0 0 H{w} V270 Q160 335 0 284Z',p['mint']);c.nav();c.text(24,142,'Small racers.',31);c.text(24,179,'Big trouble.',37,p['coral'])
  c.trail('M30 358 Q120 387 153 318 Q205 230 321 303',p['blue'],14,True);c.trail('M-20 437 Q70 403 96 447 Q175 491 285 398',p['coral'],18,True)
  c.vehicle(w*.69,390,1.42,p['coral'],-14);c.vehicle(w*.82,301,.76,p['blue'],-12);c.vehicle(70,354,.63,p['yellow'],10)
  c.text(24,515,'TURN. TRAIL. OUTLAST.',16);c.button(22,540,w-44,72,'PLAY',True)
  c.text(24,644,'MAKE YOUR MARK',12,p['blue']);c.text(25,681,'Customize',21);c.text(w-25,681,'Shop',21,anchor='end');c.path(f'M24 696 H{w-24}',stroke=p['ink'],sw=1)
  c.text(25,735,'Profile',18);c.text(w-25,735,'Settings',18,anchor='end');c.text(24,792,'3 rounds · Homing + Jump · rocket revenge',12,body=True)
 elif compact:
  c.path(f'M0 0 H270 Q220 230 300 {h} H0Z',p['mint']);c.wordmark(24,68,.6);c.text(24,155,'Small racers.',22);c.text(24,186,'Big trouble.',27,p['coral']);c.button(22,218,232,64,'PLAY',True)
  c.arena(301,62,400,400/1.625,False);c.text(300,34,'HOME · DEMO ARENA',13)
  for i,t in enumerate(['Customize','Shop','Profile','Settings']):c.text(24+i*174,h-32,t,15)
 else:
  if k=='A':c.path('M0 0 H561 Q476 160 524 341 Q457 446 0 540Z',p['mint'])
  elif k=='B':c.path('M28 24 L570 10 L600 600 L15 617Z','#E5D5AF');c.path('M70 315 L1190 435',stroke=p['coral'],sw=20)
  else:c.rect(24,104,1232,517,'#B6CFD4',36);c.rect(42,111,1196,497,p['paper'],30)
  c.nav();c.text(55,199,'Small racers.',48);c.text(55,260,'Big trouble.',61,p['coral']);c.text(58,302,'Leave a trail. Make a narrow escape.',20,body=True)
  if k=='A':
   c.trail('M590 415 Q630 210 850 265 T1138 210',p['blue'],19,True);c.trail('M493 540 Q687 540 695 452 Q702 360 820 384 Q946 410 1011 349',p['coral'],25,True);c.trail('M749 594 Q871 528 1010 565 T1211 491',p['yellow'],15,True)
   c.vehicle(1010,349,2.6,p['coral'],-18);c.vehicle(1134,213,1.05,p['blue'],-30);c.vehicle(1210,491,1.05,p['yellow'],-25)
   c.text(952,167,'DEMO / FOLLOW THE TRAILS',12,body=True);c.rocket(775,224,1.15,-25)
  elif k=='B':
   c.rect(666,185,470,330,p['paper'],0,p['ink'],2);c.rect(850,176,110,27,p['yellow']);c.trail('M684 463 Q847 479 858 378 Q866 297 1030 332',p['blue'],17);c.vehicle(1030,332,2.4,p['coral'],14);c.text(695,224,'TODAY’S TROUBLEMAKERS',17);c.text(701,494,'ONE MORE ROUND?',19)
  else:
   c.panel(634,189,545,310,'raised',p['mint']);c.trail('M670 410 Q760 460 860 400 T1087 350',p['coral'],21,True);c.vehicle(1045,340,2.5,p['coral'],-12);c.vehicle(753,248,.85,p['blue'],20);c.text(673,479,'THE TABLE IS SET. YOUR MOVE.',17)
  c.button(55,352,369,95,'PLAY',True);c.text(63,486,'3 rounds. One winner.',20);c.text(63,516,'Homing + Jump · post-death rocket control',15,body=True)
  # Navigation is a quiet shelf of words, not four interchangeable bordered cards.
  for i,t in enumerate(['Customize','Shop','Profile','Settings']):
   xx=55+i*210;c.circle(xx+9,641,8,[p['coral'],p['yellow'],p['blue'],p['mint']][i],p['ink']);c.text(xx+30,648,t,21)
  c.path('M55 672 H1165',stroke=p['ink'],sw=1)
 return c

def rank_rows(c,x,y,w,compact=False,reveal=False):
 p=c.p;rh=48 if compact else 58
 for i,(n,v,delta,col) in enumerate([('YOU',43,12,p['coral']),('Orbit',39,8,p['blue']),('Sunny',31,5,p['yellow']),('Mint',22,2,'#18978F')]):
  yy=y+i*rh
  if i==0:c.rect(x,yy-6,w,rh-3,p['mint'],8)
  c.text(x+9,yy+22,str(i+1),22);c.vehicle(x+56,yy+12,.36,col);c.text(x+83,yy+20,n,17)
  if reveal:c.text(x+w-87,yy+19,'+'+str(delta),16,p['blue'])
  c.text(x+w-13,yy+21,v,23,anchor='end');c.path(f'M{x+84} {yy+34} H{x+84+(w-113)*v/45}',stroke=col,sw=4)

def hud(k,w=1280,h=720,state='alive'):
 c=Canvas(w,h,k);p=c.p;mobile=w<600;compact=h<500
 if mobile and h<650:
  c.text(13,32,'R2 / 3',20);c.text(w-13,32,'0:24',20,anchor='end');c.text(13,60,'4 ALIVE',13);c.text(w-13,60,'YOU · 43',15,p['coral'],anchor='end')
  c.arena(12,86,w-24,(w-24)/1.625);c.vehicle(30,299,.35,p['coral']);c.text(56,305,'YOU · #1',18);c.text(14,337,'1 You 43   2 Orbit 39   3 Sunny 31',12)
  c.button(14,365,(w-40)/2,59,'HOMING',True);c.button((w+12)/2,365,(w-40)/2,59,'JUMP',selected=True);c.text(75,450,'READY',12,anchor='middle');c.text(w-75,450,'2.8s',12,anchor='middle');c.button(14,485,78,51,'◀');c.button(w-92,485,78,51,'▶');c.text(w/2,515,'HOLD TO TURN',11,anchor='middle')
 elif mobile:
  c.text(16,41,'ROUND 2 / 3',19);c.text(w-15,41,'0:24',19,anchor='end');c.text(16,70,'4 ALIVE',13);c.text(w-15,70,'YOU · 43 PTS',15,p['coral'],anchor='end')
  fw=w-24;c.arena(12,96,fw,fw/1.625);bottom=96+fw/1.625
  c.vehicle(34,bottom+48,.4,p['coral']);c.text(62,bottom+44,'YOU · #1',19);c.text(62,bottom+65,'Homing + Jump',12,body=True)
  if state=='turret':c.rocket(92,bottom+130,1.4,0,True);c.text(152,bottom+124,'ROCKET PILOT',20);c.text(152,bottom+146,'Keep steering!',15,body=True)
  else:c.text(18,bottom+113,'LIVE STANDINGS',12,p['blue']);rank_rows(c,15,bottom+139,w-30,True)
  power_y=h-199;c.button(17,power_y,(w-46)/2,64,'HOMING',True,disabled=state=='turret');c.button((w+12)/2,power_y,(w-46)/2,64,'JUMP',selected=True,disabled=state=='turret')
  c.text(95,power_y+88,'READY' if state!='turret' else 'OUT',13,anchor='middle');c.text(w-95,power_y+88,'2.8s' if state!='turret' else 'OUT',13,anchor='middle');c.path(f'M{w/2+16} {power_y+99} H{w-22}',stroke=p['blue'],sw=5)
  c.button(17,h-76,91,55,'◀');c.button(w-108,h-76,91,55,'▶');c.text(w/2,h-49,'HOLD TO TURN',12,anchor='middle');c.text(w/2,h-30,'release = straight',11,body=True,anchor='middle')
 elif compact:
  c.text(12,31,'R2 / 3',17);c.text(118,31,'0:24',17);c.text(221,31,'4 ALIVE',14);c.text(w-15,31,'YOU · 43',16,p['coral'],anchor='end')
  fw=440;c.arena(12,52,fw,fw/1.625);x=478;c.text(x,78,'YOU · #1',20);c.button(x,97,w-x-15,55,'HOMING',True);c.button(x,168,w-x-15,55,'JUMP',selected=True);c.text(x+14,247,'2.8s · CHARGING',12)
  c.button(x,h-77,91,54,'◀');c.button(w-106,h-77,91,54,'▶')
 elif w<1000:
  c.text(24,41,'ROUND 2 / 3',23);c.text(312,41,'0:24',23);c.text(w-24,41,'4 ALIVE',19,anchor='end')
  fw=w-48;c.arena(24,88,fw,fw/1.625);c.vehicle(54,580,.5,p['coral']);c.text(95,584,'YOU · #1 · 43 POINTS',23)
  c.text(28,629,'LIVE STANDINGS',14,p['blue']);rank_rows(c,26,661,w-52,True)
  c.button(25,h-170,270,65,'HOMING',True);c.button(w-295,h-170,270,65,'JUMP',selected=True)
  c.button(25,h-76,90,51,'◀');c.button(w-115,h-76,90,51,'▶');c.text(w/2,h-47,'HOLD TO TURN · RELEASE = STRAIGHT',14,anchor='middle')
 else:
  c.wordmark(31,38,.37);c.text(200,47,'ROUND 2 / 3',24);c.text(448,47,'0:24',25);c.text(583,47,'4 ALIVE',17);c.text(w-37,46,'PAUSE  II',14,anchor='end')
  fw=865;c.arena(25,93,fw,fw/1.625);x=932;c.text(x,111,'LIVE STANDINGS',16,p['blue']);rank_rows(c,x-8,141,300)
  c.vehicle(x+37,461,.68,p['coral']);c.text(x+87,454,'YOU · #1',23);c.text(x+87,479,'43 POINTS',15)
  c.button(x,525,288,58,'HOMING',True);c.button(x,606,288,58,'JUMP',selected=True);c.text(x+144,690,'2.8s · CHARGING',12,anchor='middle');c.text(29,675,'A / D  TURN',14);c.text(255,675,'W  HOMING',14);c.text(480,675,'S  JUMP',14);c.text(700,675,'release = straight',13,body=True)
 return c

def results(k,w=1280,h=720,inter=False):
 c=Canvas(w,h,k);p=c.p;mobile=w<600;c.nav()
 if mobile:
  c.text(23,134,'ROUND 2 COMPLETE' if inter else 'NICE FLYING!',28)
  c.vehicle(w/2,236,1.85,p['coral'],0,'win');c.text(w/2,328,'YOU TAKE THE LEAD' if inter else 'YOU WIN!',27,p['coral'],anchor='middle');c.text(w/2,356,'31 + 12 = 43 points' if inter else '1st of 4 · 3 rounds',16,body=True,anchor='middle')
  rank_rows(c,22,395,w-44,False,True);c.button(22,683,w-44,67,'NEXT ROUND' if inter else 'PLAY AGAIN',True);c.text(w/2,793,'SKIP ANIMATION' if inter else 'BACK HOME',13,anchor='middle')
 else:
  c.text(54,142,'SCORE RACE' if inter else 'WHAT A COMEBACK!',41)
  if k=='B':c.path('M49 185 L549 170 L564 566 L45 576Z',p['mint'],p['ink'],2)
  elif k=='C':c.panel(45,201,500,358,'raised',p['mint'])
  else:c.circle(285,358,179,p['mint'])
  c.vehicle(285,339,3.2,p['coral'],-8,'win');c.text(285,500,'YOU TAKE THE LEAD' if inter else 'YOU WIN!',30,p['coral'],anchor='middle');c.text(285,535,'31 + 12 = 43 points' if inter else '1st of 4 · 3 rounds',18,body=True,anchor='middle')
  for xx,yy in [(68,238),(495,207),(465,487)]:c.path(f'M{xx} {yy} l10 -12 m-10 12 l16 3',stroke=p['yellow'],sw=6)
  c.text(642,199,'ROUND 2 / 3' if inter else 'FINAL PLACEMENTS',17,p['blue']);rank_rows(c,622,231,567,False,True)
  c.button(644,526,412,78,'NEXT ROUND' if inter else 'PLAY AGAIN',True);c.text(1143,571,'SKIP' if inter else 'HOME',17)
  c.text(646,650,'Ranks move after score totals settle.' if inter else 'No reward granted in this design preview.',14,body=True)
 return c

def utility(screen,w=1280,h=720):
 c=Canvas(w,h);p=c.p;m=w<600
 titles={'queue':('FINDING YOUR RIVALS','Ready for a little trouble?'),'customize':('MAKE IT YOURS','Looks change. The rules stay fair.'),'shop':('THE PIT STOP','Cosmetics only · no live purchase in this preview'),'profile':('YOUR RACE RECORD','Example statistics · not a live player account'),'settings':('YOUR COMFORT ZONE','Clear controls. A little less noise.')}
 header(c,*titles[screen])
 if screen=='queue':
  if m:
   c.trail('M25 330 Q100 245 184 331 T357 330',p['blue'],12,True);c.vehicle(196,329,1.15,p['coral'],-12);c.text(w/2,452,'4 / 6 READY',26,anchor='middle');c.text(w/2,491,'You · Orbit · Sunny · Mint',14,body=True,anchor='middle');c.text(w/2,568,'Starting in 3',27,p['coral'],anchor='middle');c.button(23,687,w-46,60,'CANCEL')
  else:
   c.trail('M75 428 Q238 217 458 383 T900 362',p['blue'],19,True)
   for i,col in enumerate([p['coral'],p['blue'],p['yellow'],p['mint']]):c.vehicle(185+i*248,365,1.2,col,-12)
   c.text(61,555,'4 / 6 READY',38);c.text(61,590,'You · Orbit · Sunny · Mint',18,body=True);c.text(979,244,'3',116,p['coral']);c.text(1000,286,'GET READY',16);c.button(928,557,250,60,'CANCEL')
 elif screen in ['customize','shop']:
  if m:
   c.trail('M37 305 Q130 388 285 276',p['blue'],13,True);c.vehicle(260,278,1.45,p['blue'],-14);c.text(25,407,'RING CORE' if screen=='customize' else 'RING CORE · 150 COINS',23);c.text(25,438,'Selected for preview · not equipped',13,body=True)
   for i,(name,col) in enumerate([('Starter',p['coral']),('Ring',p['blue'])]):
    xx=24+i*180;c.panel(xx,480,160,127,fill=p['mint'] if i==1 else p['paper']);c.vehicle(xx+80,524,.64,col);c.text(xx+80,586,name,16,anchor='middle')
   c.text(25,643,'STARTER TRAIL · OWNED',14);c.text(25,676,'DASHED TRAIL · 100 COINS',14);c.button(23,721,w-46,64,'INSPECT ITEM' if screen=='shop' else 'PREVIEW ONLY',True)
  else:
   c.text(55,216,'CORE',16,p['coral']);c.text(170,216,'TRAIL',16);c.path('M52 229 H102',stroke=p['coral'],sw=4)
   for i,(name,col,state) in enumerate([('Starter core',p['coral'],'OWNED'),('Ring core',p['blue'],'150 COINS')]):
    xx=53+i*259;c.panel(xx,259,229,217,fill=p['mint'] if i==1 else p['paper']);c.vehicle(xx+115,339,1.05,col);c.text(xx+18,412,name,20);c.text(xx+18,445,state,13)
   c.text(56,538,'STARTER TRAIL',18);c.text(335,538,'OWNED',13);c.trail('M62 567 Q140 524 228 565',p['coral'],8,True);c.text(56,621,'DASHED TRAIL · 100 COINS',16)
   c.panel(663,196,554,410,fill='#E4EDDF');c.trail('M700 496 Q813 568 887 415 Q945 324 1123 345',p['blue'],17,True);c.vehicle(1097,349,2.25,p['blue'],-12);c.text(693,238,'LIVE TRAIL PREVIEW',14);c.text(694,554,'Ring core',27);c.text(694,582,'Preview ≠ owned ≠ equipped',15,body=True);c.button(713,626,450,58,'INSPECT ITEM' if screen=='shop' else 'PREVIEW ONLY',True)
 elif screen=='profile':
  if m:
   c.vehicle(74,233,1.1,p['coral'],-9);c.text(143,222,'TrailPlayer',24);c.text(143,254,'SESSION PREVIEW',12,p['blue']);c.text(24,349,'12',68);c.text(141,336,'WINS',20);c.text(141,363,'8 losses · 20 matches',13,body=True)
   lines=[('KILLS / DEATHS','31 / 24'),('POWER / TURRET HITS','46 / 9'),('LIFETIME PLAYTIME','4h 12m'),('THIS SESSION','0h 18m')]
   for i,(a,b) in enumerate(lines):yy=442+i*73;c.text(24,yy,a,13,p['blue']);c.text(24,yy+29,b,23)
   c.text(24,790,'Stats are sample values for layout review.',12,body=True)
  else:
   c.vehicle(211,326,2.6,p['coral'],-10);c.text(73,494,'TrailPlayer',35);c.text(76,525,'SESSION PREVIEW',14,p['blue']);c.text(581,277,'12',96);c.text(771,243,'WINS',27);c.text(771,275,'8 losses · 20 matches',20,body=True)
   for i,(a,b) in enumerate([('KILLS / DEATHS','31 / 24'),('POWER / TURRET HITS','46 / 9'),('LIFETIME','4h 12m'),('SESSION','0h 18m')]):
    x=572+(i%2)*322;y=374+(i//2)*132;c.text(x,y,a,13,p['blue']);c.text(x,y+46,b,35)
   c.text(75,646,'Kills require a lethal authoritative event. Hits are tracked separately.',16,body=True)
 elif screen=='settings':
  x=24 if m else 425;yy=224;rw=w-48 if m else 730
  if not m:
   for i,t in enumerate(['AUDIO','ACCESSIBILITY','CONTROLS','VISUALS']):c.text(56,239+i*76,t,21,p['coral'] if i==1 else p['ink'])
  rows=[('SFX VOLUME','70%'),('REDUCED MOTION','ON'),('VISUAL DETAIL','BALANCED'),('INPUT HINTS','AUTO'),('MUSIC','NO TRACK')]
  for i,(a,b) in enumerate(rows):
   y=yy+i*(100 if m else 78);c.text(x,y,a,13 if m else 16);c.path(f'M{x} {y+59} H{x+rw}',stroke='#BCC5BD',sw=1)
   if i==0:
    c.path(f'M{x+10} {y+33} H{x+rw-64}',stroke='#D0D7CF',sw=6);c.path(f'M{x+10} {y+33} H{x+rw*.6}',stroke=p['blue'],sw=6);c.circle(x+rw*.6,y+33,10,p['paper'],p['ink']);c.text(x+rw,y+39,b,17,anchor='end')
   elif i==1:
    c.rect(x+rw-80,y-18,78,42,p['mint'],21,p['ink']);c.circle(x+rw-23,y+3,15,p['ink']);c.text(x,y+29,'Applies immediately. No screen shake.',12,body=True)
   else:c.text(x+rw,y+32,b,17,p['blue'],anchor='end')
  c.text(x,h-65,'Audio is silent in the current Roblox build.',12,body=True)
 return c

def components():
 c=Canvas(1280,900);p=c.p;c.text(37,59,'A / CANDY COMET — PARTS WITH A PURPOSE',31);c.text(38,92,'Original separated artwork · labels stay native text · not a full-screen implementation image',16,body=True)
 for i,(t,kw) in enumerate([('PLAY',dict(primary=True)),('PRESS',dict(primary=True,pressed=True)),('SELECTED',dict(selected=True)),('DISABLED',dict(disabled=True))]):c.button(38+i*308,143,270,68,t,**kw)
 c.text(39,268,'ONE VEHICLE LANGUAGE',18,p['blue'])
 for i,col in enumerate([p['coral'],p['blue'],p['yellow'],'#18978F','#AE75BC','#E89744']):c.vehicle(103+i*208,342,1.2,col, -10 if i%2==0 else 8)
 c.text(37,429,'HOMING',15);c.rocket(167,423,1.1);c.text(310,429,'TURRET',15);c.rocket(440,423,1.1,0,True)
 c.text(39,500,'THREE SURFACES, THREE JOBS',18,p['blue']);c.button(40,538,284,62,'MAIN ACTION',True);c.panel(372,533,380,93,fill=p['mint']);c.text(394,574,'Inspection surface',22);c.text(394,603,'Quiet support, no heavy shadow.',15,body=True);c.text(820,569,'Navigation →',23);c.path('M820 583 H1015',stroke=p['coral'],sw=4)
 c.text(39,676,'PLAYING IS QUIET. WINNING GETS THE FLOURISH.',23);c.vehicle(99,755,1.0,p['coral'],0,'win');c.path('M161 727 l12 -13 M170 754 h18 M157 781 l10 11',stroke=p['yellow'],sw=4);c.text(226,755,'Essential state: OUT / PILOT / READY remains visible with motion off.',18,body=True)
 c.finish('a-component-system','component-designs')
 # Standalone reusable symbols, separate from layouts.
 for name,draw in [('hover-racer',lambda c:c.vehicle(128,123,2.4)),('homing-rocket',lambda c:c.rocket(130,128,2.7)),('turret-rocket',lambda c:c.rocket(130,128,2.7,0,True))]:
  a=Canvas(256,256);a.s=a.s[:1];draw(a);a.add('</svg>');(R/'component-designs'/(name+'.svg')).write_text(''.join(a.s),encoding='utf-8')

def states():
 c=Canvas(1280,1140);p=c.p;c.text(33,53,'A / STATE LANGUAGE',35);c.text(35,87,'State must be legible without movement, sound or color recognition.',17,body=True)
 examples=[('READY','HOMING READY','Tap to launch',{}),('CHARGING','JUMP · 2.8s','Numeric countdown + meter',dict(selected=True)),('DISABLED','JUMP · OUT','Disabled power; steering remains active',dict(disabled=True)),('LOADING','CONNECTING…','Cancel remains available',dict(disabled=True)),('SELECTED','RING CORE','Selection is not ownership',dict(selected=True)),('SUCCESS','EQUIPPED','Only after confirmation',dict(selected=True)),('ERROR','TRY AGAIN','Connection lost. Keep previous data.',{}),('ELIMINATED','OUT → ROCKET','Steer the rocket; powers stay disabled',{}),('REDUCED MOTION','READY','Same hierarchy; no lift, spin or bounce',{}),('SPECTATING','ORBIT · ALIVE','No steerable rocket available. Follow play.',{})]
 for i,(label,b,detail,kw) in enumerate(examples):
  x=34+(i%3)*421;y=146+(i//3)*230;c.text(x,y,label,14,p['blue']);c.button(x,y+27,362,58,b,**kw);c.text(x,y+123,detail,13,body=True)
 c.finish('a-important-states','component-designs')

def separate_assets():
 # Proposed sliced material skins: no baked text, interaction or full-screen art.
 for name,size,inset,fill in [('action-face-9slice',128,32,'#F66B55'),('quiet-panel-9slice',96,24,'#FFF9E9')]:
  c=Canvas(size,size);c.s=c.s[:1];p=c.p
  c.rect(3,3,size-6,size-6,fill,28 if size==128 else 20,p['ink'],3)
  if size==128:c.path(f'M27 12 H{size-27}',stroke='#FFFFFF',sw=2,extra='opacity=".6"')
  c.add('</svg>');(R/'component-designs'/(name+'.svg')).write_text(''.join(c.s),encoding='utf-8')
 c=Canvas(640,170);c.text(20,26,'ORIGINAL NAVIGATION ICONS',16)
 for i in range(4):
  x=75+i*155;y=96;p=c.p
  if i==0:
   c.path(f'M{x-28} {y+23} Q{x-9} {y+24} {x-4} {y+5}',stroke=p['blue'],sw=7);c.path(f'M{x-4} {y+5} L{x+15} {y-24}',stroke=p['ink'],sw=13);c.path(f'M{x-4} {y+5} L{x+15} {y-24}',stroke=p['coral'],sw=8)
  elif i==1:
   c.rect(x-25,y-18,50,44,p['paper'],10,p['ink'],3);c.path(f'M{x-12} {y-15} V{y-24} Q{x} {y-41} {x+12} {y-24} V{y-15}',stroke=p['ink'],sw=3);c.path(f'M{x-17} {y+6} Q{x} {y-5} {x+17} {y+6}',stroke=p['coral'],sw=5)
  elif i==2:c.vehicle(x,y,.67,p['blue'],-8)
  else:
   c.path(f'M{x-26} {y-13} H{x+26} M{x-26} {y+14} H{x+26}',stroke=p['ink'],sw=4);c.circle(x-9,y-13,9,p['yellow'],p['ink'],3);c.circle(x+11,y+14,9,p['coral'],p['ink'],3)
  c.text(x,151,['CUSTOMIZE','SHOP','PROFILE','SETTINGS'][i],12,anchor='middle')
 c.finish('navigation-icons','component-designs')

def storyboard():
 c=Canvas(1280,890);p=c.p;c.text(34,54,'A / MOTION IS A SENTENCE, NOT CONFETTI',31);c.text(35,87,'Anticipation → action → consequence → rest. All timings are proposed, not measured reference-game timings.',15,body=True)
 frames=[('01  INPUT','0–65ms','Face moves 3px. Input acts now.'),('02  RELEASE','65–180ms','Shadow returns. One small overshoot.'),('03  SCORE','0–550ms','31 + 12 → 43. Fill follows number.'),('04  REORDER','550–850ms','Stable row moves to #1.'),('05  SETTLE','850–1000ms','One 2px accent. Then still.'),('06  REMATCH','0–160ms','Clear final state; cancel old work.')]
 for i,(a,b,d) in enumerate(frames):
  x=35+(i%3)*420;y=154+(i//3)*327;c.text(x,y,a,18,p['blue']);c.text(x,y+31,b,16)
  if i<2:c.button(x+9,y+66,324,68,'PLAY',True,pressed=i==0)
  elif i<5:
   c.rect(x+6,y+62,339,73,p['mint'],12);c.vehicle(x+45,y+98,.48,p['coral']);c.text(x+85,y+104,'YOU',20);c.text(x+319,y+105,'31 +12' if i==2 else '#1 · 43',25,anchor='end')
  else:c.vehicle(x+177,y+101,1.0,p['coral'],-8);c.text(x+74,y+165,'FINDING RIVALS',20)
  c.text(x,y+209,d,13,body=True)
 c.text(36,831,'Reduced motion: immediate geometry/state changes. Static score delta and placement remain. No waiting for decoration.',15,body=True)
 c.finish('a-motion-storyboard','motion-storyboards')

def alternate_hud(k,w=1280,h=720):
 c=Canvas(w,h,k);p=c.p;m=w<600
 if k=='B':
  if m:
   c.path('M12 24 L376 17 L373 78 L17 85Z',p['mint'],p['ink'],2);c.text(25,55,'ROUND 2 / 3',20);c.text(w-24,55,'0:24',20,anchor='end');c.arena(13,112,w-26,(w-26)/1.625)
   c.text(20,383,'4 ALIVE · YOU 43',21);c.panel(20,420,w-40,213,'raised');rank_rows(c,28,441,w-56,True);c.button(20,666,168,62,'HOMING',True);c.button(203,666,168,62,'JUMP',selected=True);c.button(20,764,83,49,'◀');c.button(w-103,764,83,49,'▶')
  else:
   c.wordmark(28,51,.50);c.path('M231 26 L1228 19 L1237 78 L227 86Z',p['mint'],p['ink'],2);c.text(251,60,'ROUND 2 / 3',25);c.text(589,60,'0:24',25);c.text(858,60,'4 ALIVE',21)
   c.panel(24,154,243,256,'raised');c.text(39,185,'RACE NOTES',19);rank_rows(c,30,219,225,True);c.text(35,460,'YOU · 43 POINTS',20);c.button(24,500,242,62,'HOMING',True);c.button(24,589,242,62,'JUMP',selected=True)
   c.arena(298,134,935,935/1.625);c.text(305,103,'WATCH THE LINES. KEEP YOUR COOL.',17);c.text(310,679,'A / D TURN      W HOMING      S JUMP',16)
 else:
  if m:
   for i,t in enumerate(['R2 / 3','0:24','4 ALIVE']):c.panel(12+i*127,29,113,48,fill=p['paper']);c.text(68+i*127,60,t,16,anchor='middle')
   c.arena(16,112,w-32,(w-32)/1.625);c.text(23,394,'YOU · 43 POINTS',24)
   for i,(t,n,col) in enumerate([('YOU',43,p['coral']),('Orbit',39,p['blue']),('Sunny',31,p['yellow'])]):
    xx=68+i*127;c.vehicle(xx,476,.68,col);c.text(xx,533,n,29,anchor='middle');c.text(xx,562,t,16,anchor='middle')
   c.button(23,617,w-46,61,'HOMING',True);c.button(23,702,w-46,61,'JUMP',selected=True);c.button(23,774,74,45,'◀');c.button(w-97,774,74,45,'▶');c.text(w/2,803,'HOLD TO TURN',12,anchor='middle')
  else:
   c.text(38,48,'ROUND',16);c.circle(157,42,27,p['yellow'],p['ink']);c.text(157,51,'2',27,anchor='middle');c.text(205,48,'OF 3',16);c.text(452,48,'0:24',25);c.text(615,48,'4 ALIVE',21);c.text(937,48,'YOU · 43 PTS',24,p['coral'])
   c.arena(189,105,900,900/1.625)
   c.vehicle(80,214,.9,p['coral']);c.text(80,280,'HOMING',17,anchor='middle');c.circle(80,354,51,p['coral'],p['ink'],4);c.rocket(80,349,.9);c.text(80,433,'W · READY',14,anchor='middle')
   c.vehicle(1190,214,.9,p['blue']);c.text(1190,280,'JUMP',17,anchor='middle');c.circle(1190,354,51,p['yellow'],p['ink'],4);c.text(1190,363,'2.8s',24,anchor='middle');c.text(1190,433,'S · CHARGING',13,anchor='middle');c.text(211,697,'1 YOU 43     2 Orbit 39     3 Sunny 31     4 Mint 22',17)
 return c

def alternate_results(k):
 c=Canvas(1280,720,k);p=c.p;c.nav()
 if k=='B':
  c.text(54,153,'A PHOTO FINISH.',47);c.path('M753 114 L1196 99 L1210 480 L764 494Z',p['mint'],p['ink'],2);c.vehicle(988,291,2.7,p['coral'],10,'win');c.text(981,426,'YOU WIN!',38,anchor='middle');c.rect(907,99,125,23,p['yellow'])
  c.text(58,231,'YOUR ROUND-BY-ROUND STORY',18)
  for i,(a,b) in enumerate([('Round 1','18'),('Round 2','+12'),('Round 3','+13')]):
   x=65+i*211;c.panel(x,264,182,156);c.text(x+20,305,a,19);c.text(x+91,371,b,43,p['coral'],anchor='middle')
  c.text(58,484,'1 YOU 43     2 Orbit 39',24);c.text(58,524,'3 Sunny 31     4 Mint 22',20);c.button(56,590,459,75,'PLAY AGAIN',True);c.text(790,620,'KEEP THE GOOD RUN GOING.',20)
 else:
  c.text(640,150,'THE LITTLE CHAMPION',40,anchor='middle');c.vehicle(640,306,2.7,p['coral'],-7,'win')
  podium=[(437,451,134,107,p['blue'],'2','Orbit',39),(573,414,134,144,p['yellow'],'1','YOU',43),(709,477,134,81,p['mint'],'3','Sunny',31)]
  for x,y,w,h,col,n,name,score in podium:
   c.panel(x,y,w,h,'raised',col);c.text(x+w/2,y+44,n,39,anchor='middle');c.text(x+w/2,599,name,18,anchor='middle');c.text(x+w/2,629,score,24,anchor='middle')
  c.text(74,230,'YOU WIN!',37,p['coral']);c.text(75,271,'3 rounds · 1st of 4',18);c.text(75,305,'Mint · 4th · 22 points',15,body=True);c.button(926,495,290,78,'PLAY AGAIN',True);c.text(1004,621,'BACK HOME',17)
 return c

def moodboard(k):
 c=Canvas(1280,720,k);p=c.p;c.text(38,64,k+' / '+p['name'],38);c.text(40,101,{'A':'Taffy trails · finned comet · a single unmistakable action','B':'Racing scrapbook · cut edges · printed numbers · sticker silhouettes','C':'Tabletop runway · plinths and score tokens · molded toy surfaces'}[k],19,body=True)
 for i,key in enumerate(['paper','ink','mint','coral','blue','yellow']):
  c.circle(69+i*111,174,28,p[key],p['ink']);c.text(69+i*111,224,p[key],12,body=True,anchor='middle')
 c.vehicle(951,228,2.7,p['coral'],-13,'win');c.trail('M722 318 Q843 392 1006 319 T1223 338',p['blue'],18,True)
 c.button(40,296,368,82,'PLAY',True);c.panel(40,442,568,143,'raised',p['mint']);c.text(62,484,'A support surface, not another CTA.',22);c.text(62,518,'Typography: '+('Kalam + Arial' if k=='B' else 'Fredoka One + Arial'),18,body=True)
 c.text(714,432,'BORROW THE PRINCIPLE, NOT THE ART',18,p['blue']);
 for i,t in enumerate({'A':['PHIGHTING: character silhouette earns the spotlight.','Super Bomb Survival: action controls remain distinct.','Dandy: quiet play HUD, expressive character context.'],'B':['Block Tales: substrate, lettering and icons agree.','Super Doomspire: stickers carry personality.','Snipperclips: shape is character, not decoration.'],'C':['Tower Heroes: inspect one character at a time.','Mario Party: placement gets a physical metaphor.','Toy construction: depth reserved for touched surfaces.']}[k]):c.text(714,470+i*39,t,14,body=True)
 c.text(40,659,'Original material study. Reference images, links, dates and limitations are in the separate research section.',15,body=True);c.finish(k.lower()+'-moodboard','concepts')

for k in PALETTES:
 for label,fn in [('home',home),('hud',hud if k=='A' else alternate_hud),('results',results if k=='A' else alternate_results)]:fn(k).finish('concept-'+k.lower()+'-'+label+'-desktop','concepts',PALETTES[k]['name']+' / '+label)
 (hud if k=='A' else alternate_hud)(k,390,844).finish('concept-'+k.lower()+'-hud-portrait','concepts');moodboard(k)
for label,fn in [('home',lambda w,h:home('A',w,h)),('hud',lambda w,h:hud('A',w,h)),('inter-round',lambda w,h:results('A',w,h,True)),('results',lambda w,h:results('A',w,h))]+[(s,lambda w,h,s=s:utility(s,w,h)) for s in ['queue','customize','shop','profile','settings']]:
 for w,h,device in [(1280,720,'desktop'),(390,844,'portrait')]:fn(w,h).finish('a-'+label+'-'+device,label=label+' / '+device)
home('A',749,381).finish('a-home-landscape');hud('A',749,381).finish('a-hud-landscape');hud('A',390,844,'turret').finish('a-turret-portrait');hud('A',768,1024).finish('a-hud-tablet')
home('A',320,568).finish('a-home-small-portrait');hud('A',320,568).finish('a-hud-small-portrait')
components();states();storyboard();separate_assets()
(R/'manifest.json').write_text(json.dumps(MAN,indent=2),encoding='utf-8')
print('Authored',len(MAN),'editable proposal boards')
