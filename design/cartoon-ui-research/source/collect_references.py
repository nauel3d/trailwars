"""Download selected public research screenshots; never used as Trail Wars assets."""
from pathlib import Path
import json, requests, hashlib
from PIL import Image, ImageDraw, ImageOps
ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'references'; OUT.mkdir(parents=True,exist_ok=True)
# Dates below describe the source, not a claim that the pictured interface is current.
refs=[
('block-tales','Block Tales','Paper RPG','2024-06 article','https://www.roblox.com/games/16483433878/Block-Tales','https://www.sportskeeda.com/roblox-news/block-tales-cards-tier-list','https://staticg.sportskeeda.com/editor/2024/06/4aae7-17177487838497-1920.jpg','Battle action menu / HUD','https://www.youtube.com/watch?v=2YgTTbc7qwI'),
('tower-heroes','Tower Heroes','Character collection / tower defense','2023-12 article','https://www.roblox.com/games/4646477729/Tower-Heroes','https://thenerdstash.com/all-towers-in-tower-heroes-ranked-tier-list/','https://image.thenerdstash.com/2023/12/Tower-Heroes-tier-list-1.jpg','Collection menu','https://www.youtube.com/watch?v=DuZLyejIngA'),
('tower-heroes-hud','Tower Heroes','Gameplay companion','2024-07 article','https://www.roblox.com/games/4646477729/Tower-Heroes','https://www.sportskeeda.com/roblox-news/tower-heroes-cake-factory-guide','https://staticg.sportskeeda.com/editor/2024/07/95bc7-17202666569895-1920.jpg','Wave / unit HUD',''),
('phighting','PHIGHTING!','Competitive character action','2026 post; historical capture version unknown','https://www.roblox.com/games/7138009149/PHIGHTING','https://x.com/2ThousandSunny/status/2034021283617288699','https://pbs.twimg.com/media/HDpI5PNXAAAR-xK.jpg','Character selection','https://www.youtube.com/watch?v=cLBXYI88ZzY'),
('bomb-survival','Super Bomb Survival','Arcade survival','2022 forum thread; historical','https://www.roblox.com/games/164051105/Super-Bomb-Survival','https://forum.arcaneodyssey.dev/t/super-bomb-survival-pics-here/82618','https://forum.arcaneodyssey.dev/uploads/default/original/3X/c/9/c950158e72ae6b009ed1bd0238f3d7385b85a63d.jpeg','Live gameplay HUD','https://www.youtube.com/watch?v=2ALQWr-FuUQ'),
('bomb-menu','Super Bomb Survival','Developer material','2019 developer update','https://www.roblox.com/games/164051105/Super-Bomb-Survival','https://x.com/tylermcbride/status/1094617549638127616','https://pbs.twimg.com/ext_tw_video_thumb/1094617003732672512/pu/img/ne7TxKdj-ChPjzun.jpg','Developer video poster: lobby signage, not menu interaction','https://x.com/tylermcbride/status/1094617549638127616'),
('bee-swarm','Bee Swarm Simulator','Icon-driven collection','2019 official Roblox video post; historical','https://www.roblox.com/games/1537690962/Bee-Swarm-Simulator','https://x.com/Roblox/status/1102628079325900800','https://pbs.twimg.com/ext_tw_video_thumb/1102627989286801409/pu/img/jhahWHrD_g6OwJOY.jpg','Inventory and resource HUD','https://www.youtube.com/watch?v=iHVZy-JM3AU'),
('dandy-menu',"Dandy's World",'Mascot / survival','2024-07 article','https://www.roblox.com/games/16116270224/Dandys-World','https://thenerdstash.com/the-ultimate-beginners-guide-to-dandys-world-roblox/','https://image.thenerdstash.com/2024/07/trinkets-dandys-world-roblox-1024x576.jpg','Trinket menu / character integration',''),
('dandy-hud',"Dandy's World",'Gameplay companion','2024-08 article','https://www.roblox.com/games/16116270224/Dandys-World','https://www.sportskeeda.com/roblox-news/dandys-world-toon-tier-list','https://staticg.sportskeeda.com/editor/2024/08/4bdb2-17250374627087-1920.jpg','Floor / hearts / stamina HUD',''),
('doomspire','Super Doomspire','Competitive toy combat','Roblox listing retrieved 2026-11-10; capture date unknown','https://www.roblox.com/games/3725149043/Super-Doomspire','https://www.roblox.com/games/3725149043/Super-Doomspire','https://tr.rbxcdn.com/180DAY-bc7a42db15273a67a8822a22d25d1891/768/432/Image/Webp/noFilter','Inventory / tooltip','https://www.youtube.com/watch?v=Pp4ZFiap05E'),
('doomspire-art','Super Doomspire','Developer material','2019 sketch, shared 2022','https://www.roblox.com/games/3725149043/Super-Doomspire','https://x.com/tylermcbride/status/1557499803172573184','https://pbs.twimg.com/media/FZ1ZWYKXgAENehH.png','Developer arena sketch, not shipped UI',''),
('epic-menu','Epic Minigames','Party / short rounds','2024-05 article','https://www.roblox.com/games/277751860/Epic-Minigames','https://www.sportskeeda.com/roblox-news/epic-minigames-guide','https://staticg.sportskeeda.com/editor/2024/05/f8fed-17150342854112-1920.jpg','Quick Play menu','https://www.youtube.com/watch?v=3oePOQvgRP4'),
('epic-hud','Epic Minigames','Gameplay companion','2024-05 article','https://www.roblox.com/games/277751860/Epic-Minigames','https://www.sportskeeda.com/roblox-news/epic-minigames-guide','https://staticg.sportskeeda.com/editor/2024/05/b753b-17150345328653-1920.jpg','Achievement menu / round winner banner',''),
]
records=[]
for key,name,category,date,game,page,url,kind,video in refs:
    record=dict(id=key,game=name,category=category,sourceDate=date,official=game,page=page,imageURL=url,kind=kind,video=video,accessDate='2026-11-10',videoStatus='Linked source only; moving playback and audio not inspected')
    try:
        r=requests.get(url,timeout=25);r.raise_for_status();raw=r.content
        p=OUT/(key+'.'+('png' if 'png' in r.headers.get('Content-Type','') else 'jpg'))
        p.write_bytes(raw)
        with Image.open(p) as im: record['dimensions']=list(im.size)
        record.update(file=p.name,status='Downloaded; visually inspect before analysis',sha256=hashlib.sha256(raw).hexdigest())
    except Exception as e: record.update(status='Unavailable',error=str(e))
    records.append(record)
    print(key,record['status'])
(OUT/'sources.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
tiles=[]
for r in records:
    if 'file' not in r: continue
    tile=Image.new('RGB',(480,330),'#f4f0e8');draw=ImageDraw.Draw(tile)
    im=Image.open(OUT/r['file']).convert('RGB');im.thumbnail((472,275))
    tile.paste(im,((480-im.width)//2,32+(275-im.height)//2));draw.text((10,8),r['id'],fill='#192a46');tiles.append(tile)
sheet=Image.new('RGB',(480*3,330*((len(tiles)+2)//3)),'white')
for i,t in enumerate(tiles):sheet.paste(t,(i%3*480,i//3*330))
sheet.save(OUT/'inspection-sheet.jpg')
