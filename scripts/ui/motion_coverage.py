"""Map all preserved screen proposals to the shared motion policy, no art rewrite."""
import json
from pathlib import Path
root = Path(__file__).resolve().parents[2]
pages = json.loads((root/'design/ui-fresh-direction/mockup-manifest.json').read_text(encoding='utf-8'))
def family(slug):
    for words, policy in [(['home'], 'home-navigation'), (['component','design-system','storyboard'],'components'), (['controls'],'controls'), (['queue','countdown'],'queue-countdown'), (['customize','item-details'],'customize-preview'), (['purchase','funds','shop'],'shop-transaction'), (['profile'],'profile-standings'), (['settings'],'settings'), (['elimination','spectator'],'elimination-spectator'), (['hud'],'hud'), (['victory','defeat','rewards'],'results-rewards'), (['leave'],'confirmation')]:
        if any(word in slug for word in words): return policy
    return 'loading-recovery'
out=[{'slug':p['slug'],'policy':family(p['slug']),'states':p['states'],'implementation':'demo-first; remaining routes await visual approval'} for p in pages]
assert len(out)==46 and len({p['slug'] for p in out})==46
(root/'design/motion-system/screen-coverage.json').write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8')
print('MOTION COVERAGE: 46 preserved proposals mapped; no original proposal modified')
