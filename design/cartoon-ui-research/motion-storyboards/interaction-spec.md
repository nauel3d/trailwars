# Motion and audio storyboard — proposed A

Design only. Reference footage is linked but timings below are original recommendations, not observed Nintendo/Roblox measurements. Existing SNAP motion tokens and cleanup contracts are the starting point. The HTML workbench demonstrates intent locally; it is not Roblox gameplay.

| Event | Movement / timing / easing | Emphasis, interruption and reduced motion | Original audio candidate |
|---|---|---|---|
| Play press | Face down 3px /65ms QuadOut; return /115ms short BackOut | Action dispatches immediately; stable hit rectangle. Cancel hover/focus tween. Reduced: tint + immediate compressed state. | press, 70ms downward chirp; one cue per activation, not every hover |
| Navigation | Active trail underline changes /100ms; new content settles 6px /160ms QuadOut | One latest route; restore origin focus on back. Reduced: immediate swap. | select or back; no ambient menu loop |
| Cosmetic select | Selected edge transfers /100ms; preview tilts ≤4° /180ms | Preview is not equip. New selection cancels old tilt. Reduced: still front pose. | select; confirm only on confirmed equip |
| Homing | Button compresses; small muzzle/exhaust /120ms; numeric cooldown starts from server state | No animation delay before intent. No fabricated hit from launch. Reduced: static launch state/icon. | launch, 130ms rising tone |
| Jump | Shell lifts ≤5px /80ms; ground anchor/AIR remains; short landing ring /180ms | Event duration follows existing power; decorative lift does not change physics. Reduced: AIR + static anchor, no lift. | jump, 190ms ascending chirp |
| Countdown | Numeral replaces crisply; GO settles 4px /150ms then clears by 300ms | Short, arena remains visible. Latest round ID cancels old countdown. Reduced: stationary text. | go, 200ms three-note cue, once at GO |
| Elimination | One local impact /300–480ms; OUT text immediate | Authoritative event only. Never cover steering/pilot controls. Reduced: static OUT, no particles or camera movement. | crash, 150ms lower/noisy descent |
| Turret transition | Original rocket pilot symbol turns once ≤8° /180ms; instruction swaps immediately | No delay in steerability. Stop on spectate/new round; reduced: static symbol. | No extra cue stacked on crash; launch on actual rocket launch |
| Confirmed hit | One small ring/value /200–300ms | Nonlethal feedback distinctly smaller than crash. Sequence/round dedup. Reduced: brief static TAG. | hit, 85ms down-chirp; never a victory sound |
| Round score | Previous total → explicit delta → count-up + fill /550ms CubicOut | Sample 31 +12 =43; real implementation uses authoritative ledger. Skip commits latest final values. Reduced: all numbers immediately. | settle once, 175ms; avoid one sound per point |
| Rank reorder | Stable-ID rows move to new positions /300ms QuadInOut; local up-row accent 2px /150ms | Coalesce new order, cancel old tween; quiet live HUD uses no bounce. Reduced: direct order with placement text. | rank, 190ms three-note rise only for own improvement |
| Victory | Winner pose ≤8° +one settle /450ms, up to 6 small marks /650ms | Rematch available throughout. No arena obstruction during active play. Reduced: static smile/placement. | victory, 510ms four-note fanfare, once |
| Defeat | Character relaxed pose; placement fades in /120ms | No humiliating shake or giant failure screen; clear rematch. Reduced: immediate. | settle softly, or silence; not crash repeated |
| Rematch | Old winner/score work canceled now; next-state panel settles /160ms | Discard old final presentation before next queue. Server Join acknowledgement remains authoritative. Reduced: direct switch. | confirm once; no reward replay |
| Loading / error | Local low-frequency indicator only while visible; error persists with retry/back | Cancel/disconnect always usable; uncertain data remains uncertain. Reduced: still label. | warning once per actionable error; no repeated alarm |

## Lifecycle policy

Key all animation work to a screen scope, round ID and generation. New state cancels the previous scope; dispose Tween completion callbacks, animation instances, delayed work and event listeners. Hide, destroy, round reset, respawn and rematch all perform cleanup. No per-frame rebuilding. Score row IDs persist; old roster members are pruned. Decorations are pooled and bounded. Reduced motion applies at the moment of preference change, independently from graphics quality and sound.

The browser motion workbench has explicit Play/Skip, cancels pending timers/animations on reset, visibility loss and reduced-motion changes. It never runs ambient loops without user input. Its sample standings are clearly labeled and never sent to Roblox.

## Existing audio review and proposed fit

Reviewed the existing synthesis source, WAV headers and `AudioCatalog`; this is a structural/pitch/duration review, not a claimed listening or in-engine playback test. Eleven new cues are original deterministic 44.1kHz mono synthesis; select/confirm/warning are preserved older originals. Attack/decay envelopes and the short chirps are suitable candidates for a small toy language, but the tonal mix needs an actual listening review before visual approval becomes audio approval.

Use lower, slightly noisy press/crash transients for physical weight; rising tonal Jump/GO/rank for anticipation and accomplishment. Victory is the only longer phrase. Muted play must remain fully understandable. Avoid simultaneous launch/crash/rank stacking; priority system and a small voice cap already exist. No copied commercial sounds. No music track is currently supplied; settings must not imply music is playing.

The gallery's optional audio players use original local WAVs, not Roblox asset IDs. Asset upload and sound implementation are explicitly outside this phase. The preserved Roblox build is silent because asset:read was denied; no new scope checks, upload or fabricated IDs here.
