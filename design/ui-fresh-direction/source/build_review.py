"""Create a local design review gallery and validate authored layout bounds."""
from pathlib import Path
import html
import json
from PIL import Image

PLAN = Path(__file__).resolve().parents[1]
pages = json.loads((PLAN / 'mockup-manifest.json').read_text(encoding='utf-8'))
errors = []
home_checks = []
for page in pages:
    w, h = page['viewport']
    if Image.open(PLAN / 'mockups' / (page['slug'] + '.png')).size != (w, h):
        errors.append([page['slug'], 'PNG dimensions differ from manifest'])
    for action in page['actions']:
        x, y, aw, ah = action['rect']
        if min(x, y) < 0 or x + aw > w + .01 or y + ah > h + .01:
            errors.append([page['slug'], action['id'], 'outside viewport'])
    if page['title'] == 'Home':
        actions = page['actions']
        ids = {a['id'].upper() for a in actions}
        if ids != {'PLAY', 'CUSTOMIZE', 'SHOP', 'PROFILE', 'SETTINGS'}:
            errors.append([page['slug'], 'missing Home destination'])
        for i, a in enumerate(actions):
            x, y, aw, ah = a['rect']
            if min(aw, ah) < 48:
                errors.append([page['slug'], a['id'], 'target below 48 logical pixels'])
            for b in actions[i + 1:]:
                bx, by, bw, bh = b['rect']
                if min(x + aw, bx + bw) > max(x, bx) and min(y + ah, by + bh) > max(y, by):
                    errors.append([page['slug'], a['id'], b['id'], 'overlap'])
        home_checks.append({'slug': page['slug'], 'viewport': [w, h], 'actions': len(actions)})

report = {'kind': 'static design geometry checks; not Roblox verification',
          'screens': len(pages), 'homeChecks': home_checks, 'errors': errors}
(PLAN / 'qa/layout-checks.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')

cards = []
for page in pages:
    slug = html.escape(page['slug'])
    title = html.escape(page['title'])
    w, h = page['viewport']
    states = html.escape(', '.join(page['states']))
    cards.append(f'''<article data-name="{title.lower()} {slug}"><h3>{title}</h3>
<a href="mockups/{slug}.png"><img loading="lazy" src="mockups/{slug}.png" alt="{title}, {w} by {h} proposal"></a>
<p>{w} × {h} · <a href="mockups/{slug}.svg">Editable SVG</a></p><p>{states}</p></article>''')

document = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Trail Wars — replacement design review</title><style>
*{box-sizing:border-box}body{margin:0;background:#dff4e8;color:#192a46;font:17px/1.5 Arial,sans-serif}main{max-width:1500px;margin:auto;padding:28px}h1{font-size:clamp(30px,5vw,60px);line-height:1.1;margin:15px 0}h2{margin-top:42px}a{color:#233d87}p{max-width:85ch}header{background:#fffcf3;padding:25px;border:2px solid #192a46;border-radius:18px;box-shadow:0 5px #192a46}label{display:block;margin:28px 0 12px}input{font:inherit;width:min(100%,600px);padding:12px;border:2px solid #192a46;border-radius:10px}.concepts,.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(290px,1fr));gap:22px}article,figure{margin:0;background:#fffcf3;border:2px solid #192a46;border-radius:14px;padding:15px;overflow:hidden}img{max-width:100%;height:auto;display:block;margin:auto}.grid img{height:280px;width:100%;object-fit:contain}.concepts img{height:320px;width:100%;object-fit:contain}h3{margin:0 0 12px;font-size:20px}article p{font-size:14px}button{font:inherit;background:#ff6957;color:#192a46;border:2px solid #192a46;border-radius:8px;padding:10px 18px;cursor:pointer}footer{padding:30px 0} [hidden]{display:none!important}
</style><main><header><h1>A fresh Trail Wars</h1><p>Mint, warm white, ink and coral. Crisp controls, open space, circular cores and separate layouts for desktop and phone.</p><p><strong>Design proposals only.</strong> These are not Roblox captures. This page is a review gallery; the proposed Home screen has no page scrolling.</p><p><a href="README.md">Design and implementation decision</a> · <a href="qa/layout-checks.json">Static layout checks</a> · <a href="../ui-master-plan/navigation-and-state-machine.md">Navigation and states</a></p></header>
<h2>Art direction</h2><div class="concepts"><figure><a href="home-desktop.png"><img src="home-desktop.png" alt="New desktop Home concept"></a><figcaption>Desktop Home — art direction</figcaption></figure><figure><a href="home-mobile.png"><img src="home-mobile.png" alt="New portrait Home concept"></a><figcaption>Portrait Home — art direction</figcaption></figure><figure><a href="customize-desktop.png"><img src="customize-desktop.png" alt="New Customize concept"></a><figcaption>Customize — art direction</figcaption></figure></div>
<h2>Complete screen and state proposals</h2><p>The editable layouts below specify placement and state coverage. They use simpler artwork than the concept paintings. Open an image at its authored size to inspect it.</p><label for="search">Filter screens</label><input id="search" type="search" placeholder="Home, Customize, settings, mobile…"><p id="count" aria-live="polite"></p><div class="grid">''' + '\n'.join(cards) + '''</div><footer>Approval checkpoint: approve the replacement design before production implementation. Existing gameplay, server economy and tests remain preserved.</footer></main><script>
const input=document.querySelector('#search'),cards=[...document.querySelectorAll('article')],count=document.querySelector('#count');function filter(){let n=0;for(const c of cards){c.hidden=!c.dataset.name.includes(input.value.toLowerCase());if(!c.hidden)n++}count.textContent=n+' proposals shown'}input.addEventListener('input',filter);filter();
</script></html>'''
(PLAN / 'index.html').write_text(document, encoding='utf-8')
print(json.dumps(report))
if errors:
    raise SystemExit(1)
