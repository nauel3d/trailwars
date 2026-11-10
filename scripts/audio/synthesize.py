"""Original short arcade cues, deterministic synthesis, no samples. Preserve existing WAVs."""
from pathlib import Path
import math, random, struct, wave, json

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets'/'snap-audio'
RATE=44100
SPECS={
 'press':[(220,170,.07)], 'back':[(880,580,.065)],
 'queue':[(660,660,.06),(880,880,.09)],
 'go':[(523,523,.05),(659,659,.05),(1047,1047,.10)],
 'jump':[(250,760,.19)], 'launch':[(160,480,.13)],
 'hit':[(220,140,.085)], 'crash':[(150,65,.15)],
 'rank':[(659,659,.055),(784,784,.055),(988,988,.08)],
 'settle':[(523,523,.075),(659,659,.10)],
 'victory':[(523,523,.09),(659,659,.09),(784,784,.11),(1047,1047,.22)],
}
for name,notes in SPECS.items():
 path=OUT/f'{name}.wav'
 if path.exists(): continue
 rng=random.Random(name)
 samples=[]
 for first,last,duration in notes:
  count=int(RATE*duration)
  phase=0.0
  filtered=0.0
  for i in range(count):
   t=i/RATE;u=i/max(1,count-1)
   frequency=first+(last-first)*u
   phase+=2*math.pi*frequency/RATE
   envelope=min(1,t/.004)*math.exp(-3*u)*(1-u)**.3
   filtered=.82*filtered+.18*rng.uniform(-1,1)
   noise=.23*filtered if name in ('press','launch','crash','hit') else 0
   value=(math.sin(phase)+.15*math.sin(2*phase)+noise)*envelope
   samples.append(value)
 peak=max(abs(v) for v in samples) or 1
 pcm=b''.join(struct.pack('<h',round(v/peak*.42*32767)) for v in samples)
 with wave.open(str(path),'wb') as stream:
  stream.setnchannels(1);stream.setsampwidth(2);stream.setframerate(RATE);stream.writeframes(pcm)
manifest={'origin':'Original deterministic additive/chirp synthesis, no samples or licensed commercial audio',
 'rate':RATE,'newCues':SPECS,'preserved':['select.wav','confirm.wav','warning.wav'],
 'robloxStatus':'Silent. asset:read permission check failed; no fabricated asset IDs, no upload attempted.'}
(OUT/'polish-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
print(f'Prepared {len(SPECS)} additional cues; preserved original three WAVs.')
