"""Preserve public Roblox presentation evidence. No login, gameplay or cookies."""
import concurrent.futures, hashlib, json, pathlib, urllib.request
from datetime import datetime, timezone
ROOT = pathlib.Path(__file__).resolve().parent
GAMES = [('rivals',17625359962),('blade-ball',13772394625),('epic-minigames',277751860),('super-bomb-survival',164051105),('dandys-world',16116270224),('dress-to-impress',15101393044),('doors',6516141723)]
def get(url):
    req=urllib.request.Request(url,headers={'User-Agent':'TrailWarsDesignResearch/1.0'})
    return urllib.request.urlopen(req,timeout=45).read()
def fetch(entry):
    slug,place=entry
    result={'slug':slug,'placeId':place,'url':f'https://www.roblox.com/games/{place}','retrievedUTC':datetime.now(timezone.utc).isoformat(),'images':[]}
    try:
        universe=json.loads(get(f'https://apis.roblox.com/universes/v1/places/{place}/universe'))['universeId']
        result['universeId']=universe
        result['details']=json.loads(get(f'https://games.roblox.com/v1/games?universeIds={universe}'))['data'][0]
        icon=json.loads(get(f'https://thumbnails.roblox.com/v1/games/icons?universeIds={universe}&size=512x512&format=Png&isCircular=false'))['data']
        thumbs=json.loads(get(f'https://thumbnails.roblox.com/v1/games/multiget/thumbnails?universeIds={universe}&countPerUniverse=2&defaults=true&size=768x432&format=Png&isCircular=false'))['data'][0]['thumbnails']
        for kind,items in [('icon',icon),('thumbnail',thumbs)]:
            for i,item in enumerate(items):
                if item.get('state')!='Completed': continue
                url=item['imageUrl']; data=get(url); filename=f'{slug}-{kind}-{i+1}.png'
                (ROOT/'images').mkdir(exist_ok=True)
                (ROOT/'images'/filename).write_bytes(data)
                result['images'].append({'file':'images/'+filename,'url':url,'sha256':hashlib.sha256(data).hexdigest(),'kind':kind,'evidence':'public current API image, not an in-game menu capture'})
    except Exception as error: result['error']=str(error)
    return result
if __name__=='__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool: results=list(pool.map(fetch,GAMES))
    (ROOT/'references.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
    print(json.dumps([{'game':r['slug'],'images':len(r['images']),'error':r.get('error')} for r in results]))
