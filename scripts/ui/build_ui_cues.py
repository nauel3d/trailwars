"""Original tiny UI cues; additive sine synthesis, no sampled/copyrighted audio."""
from pathlib import Path
import math, struct, wave, json
out=Path(__file__).resolve().parents[2]/'assets/snap-audio';out.mkdir(exist_ok=True)
specs={'select':[(660,.045),(880,.055)],'confirm':[(660,.06),(880,.06),(1100,.11)],'warning':[(440,.08),(370,.10)]}
for name,notes in specs.items():
    samples=[]
    for frequency,duration in notes:
        count=int(44100*duration)
        for i in range(count):
            t=i/44100;envelope=min(1,t/.005)*max(0,1-t/duration)**1.7
            value=(math.sin(2*math.pi*frequency*t)+.16*math.sin(4*math.pi*frequency*t))*.19*envelope
            samples.append(struct.pack('<h',round(32767*value)))
    with wave.open(str(out/(name+'.wav')),'wb') as f:
        f.setparams((1,2,44100,len(samples),'NONE','not compressed'));f.writeframes(b''.join(samples))
(out/'manifest.json').write_text(json.dumps({'origin':'Original additive synthesis, no samples','rate':44100,'cues':specs,'robloxStatus':'Upload pending asset scopes/directory approval; no fabricated IDs'},indent=2)+'\n',encoding='utf-8')
print('Created 3 original short UI cues')
