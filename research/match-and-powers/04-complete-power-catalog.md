# Complete installed power catalog

Inspected 2026-11-09. Installed Steam build26292297 / previously observed game UI4.3.0. This is a complete inventory of the **discovered client enum/config/factory scope**, not a claim to know the commercial server or every remotely enabled future ability. There are **31 concrete factory-supported candidates: 9 Shots, 4 Bombs, 10 Powers, 8 Fevers**. The separate Random101 selector and orphan Saber declaration are also recorded in the CSV, giving33 rows total. Never interpret33 as the playable-power count. Public documentation saying30 is a version discrepancy. The loadout screenshotS43 shows Homing and Jump plus the29 level-gated candidates; only those two were observed available for that account.

The companion CSV contains all per-entry fields, numeric defaults, mode overrides, activation, counterplay, mobile/network implications, provenance and explicit unknowns. Stats below are **client declarations only**, not live measurements. Milliseconds are configuration values; the50Hz tick can quantize effects. Distances are game units, and projectile speed is an **addition to ship speed per simulation tick**, not units/second. Do not treat an attack value153 as153 health damage: it is a permille parameter in percentage scoring, with separate flat-stat alternatives.

## Common lifecycle and interpretation

- P-COMMON: ActiveAbility validates canUseAbilities and cooldown, returns distinct denial outcomes, starts cooldown on success, decrements it using the ship cooldown-speed stat and resets to initial cooldown on round reset. Missing initial-cooldown falls back to normal cooldown. Initial freeze effects and mode settings can delay when recharge actually begins.
- Default two slots use UP/DOWN actions. Extra Power is a separate room setting. No per-power slot eligibility restriction was recovered from the listed metadata. Unlock levels are a client level-up declaration; server entitlement remains unverified. Homing/Jump starter availability is screenshot evidence, not a guessed missing level.
- Defense is an **equipped passive score-loss reduction**: two residual multipliers multiply, e.g.250 defense means0.75 residual before the other slot. Active Shield protection is a separate collision/hit-reason effect. Extra-slot defense selection has its own branch; see the score report.
- Most dropped items arm only after movement stops. Releasing a held throw or repressing may stop it. A DOWN-slot throw is reversed relative to ship heading. Owners are ignored for the first1s by generic collectable collision, then may collect their own obstacle. Friendly-fire and authoritative eligibility cannot be established from that generic client path.
- Client fatal collision/death checks and several hit callbacks are empty. Curve.createHit at byte5420200 returns false; Curve.hit consumes accepted hit payloads and adds a mode-configured brief no-draw/no-collision grace effect, so a steal is not inherently a geometric elimination. ZapEffect.onInRange is empty; Collision.explosionHitBody does not enumerate authoritative damage. Local visuals, counters and hooks must not be presented as recovered server logic.
- The proposed Trail Wars launch remains powers-free. Any representative Shield/One Shot/Jump proof requires owner choice and approval; no power engine or new live mode is implemented by this research.

## Readable per-power reference

| ID | Name / category | Cooldown / initial (ms) | Effect duration (ms) | Functional summary |
|---|---|---:|---:|---|
| 1 | One Shot / Shots | 4000.0 / 4500 | not configured / instantaneous or projectile lifetime | One forward fireball. |
| 2 | Double Shot / Shots | 4000.0 / 4500 | not configured / instantaneous or projectile lifetime | Two simultaneous fireballs at -30/+30 degrees. |
| 3 | Side Shot / Shots | 4000.0 / 4500 | not configured / instantaneous or projectile lifetime | Two fireballs at +90/-90 degrees to heading. |
| 4 | Multi Shot / Shots | 4250 / 4500 | not configured / instantaneous or projectile lifetime | Four diagonal fireballs at -45/-135/+45/+135 degrees. |
| 5 | Scatter Shot / Shots | 5250 / 5500 | not configured / instantaneous or projectile lifetime | Nine short-range shots emitted as a spread over time. |
| 6 | Laser / Shots | 6000.0 / 6000.0 | 80 | 600ms wind-up then an 80ms forward ship ray; charging slows movement and steering. |
| 7 | Homing / Shots | 3500 / 4500 | not configured / instantaneous or projectile lifetime | Forward fireball searches near itself and steers toward the closest found core. |
| 8 | Mine / Bombs | 6000.0 / 6000.0 | not configured / instantaneous or projectile lifetime | Throw, stop, arm, then detonate on pickup/contact; explosion cuts nearby trail geometry. |
| 9 | Time Bomb / Bombs | 6500 / 6500 | not configured / instantaneous or projectile lifetime | Throw and arm; detonate after the additional timer without contact. |
| 10 | Trigger Bomb / Bombs | 6250 / 6250 | not configured / instantaneous or projectile lifetime | Throw; later activation stops a moving bomb or triggers the stationary armed bomb. |
| 11 | Stealth Mine / Bombs | 6000.0 / 6000.0 | not configured / instantaneous or projectile lifetime | Hidden mine periodically reveals; expires after its configured active lifetime. |
| 12 | Brake / Powers | 5250 / 5250 | 2000.0 | Slow movement to 0.4x and turn rate to 1.1x for tighter arcs. |
| 13 | Speed Burst / Powers | 6000.0 / 6000.0 | 2700 | Speed Burst applies 2x movement and 1.65x turn rate. |
| 14 | Jump / Powers | 6000.0 / 6000.0 | 450 | Brief no-draw/no-collision forced state represented as a HoleEffect. |
| 15 | Shield / Powers | 5000.0 / 5000.0 | 1500 | Timed shield blocks declared attack hit reasons and reflects projectiles at 0.8x base attack with new ownership. |
| 16 | Zap / Shots | 5750 / 5750 | 400 | Short nearby-core pulse represented by an emit body around the caster. |
| 17 | Angle Turns / Powers | 7000.0 / 7000.0 | 4500 | Angle Turns converts each new held-direction edge into an immediate 90-degree turn. |
| 18 | Thin / Powers | 1000.0 / 4000.0 | 99999 | Toggle reduced radius and slightly faster turning; can cancel early; cooldown freezes while thin effects exist. |
| 19 | Hide Self / Powers | 5700 / 5700 | 3500 | Hide Self stops visible trail drawing; reactivation cancels it. Other ability use, hits and item pickups can reveal the player. |
| 20 | Thick / Fevers | 4500 / 4500 | 5000.0 | Throw an obstacle; collector receives 1.65x thickness. |
| 21 | Speedy / Fevers | 4500 / 4500 | 2000.0 | Throw an obstacle; collector accelerates to 1.8x with 1.25x turning. |
| 22 | Steer-less / Fevers | 4500 / 4500 | 5000.0 | Throw an obstacle; collector turn rate becomes 0.75x. |
| 23 | Reverse / Fevers | 4500 / 4500 | 5000.0 | Throw an obstacle; collector left/right input directions are inverted. |
| 24 | Clock Block / Fevers | 4500 / 4500 | 5000.0 | Throw an obstacle; collector cooldown recharge multiplier becomes zero; Thin cancels on this stack. |
| 25 | Low-res / Fevers | 4500 / 4500 | 5000.0 | Throw an obstacle; collector receives a pixelation filter. |
| 26 | Curve-blind / Fevers | 4500 / 4500 | 1600 | Throw an obstacle; collector receives the curve-hiding filter. |
| 27 | Trippy / Fevers | 4500 / 4500 | 5000.0 | Throw an obstacle; collector receives a distorted-view filter. |
| 28 | Teleport / Powers | 6250 / 6250 | not configured / instantaneous or projectile lifetime | Throw a token, stop it, freeze during a short schedule, then relocate and optionally copy token heading. |
| 29 | 180 / Powers | 6250 / 6250 | not configured / instantaneous or projectile lifetime | Instantly reverse heading by 180 degrees and cut a small hole in front of the reversed direction. |
| 30 | Power Dash / Powers | 6000.0 / 6000.0 | 200 | Power Dash gives a very short straight high-speed burst; client death-prehook cancels death during its active window. |
| 31 | Boomerang / Shots | 5000.0 / 4500 | not configured / instantaneous or projectile lifetime | Projectile slows outbound, turns back at its distance limit or border and homes toward its owner; passes trails by configuration. |

## Mode and lifecycle exceptions

- Thin:1000ms normal cooldown,4000ms initial,99999ms configured effect; freezeCooldown remains true while Thin effects exist. A second activation cancels; the DISABILTY/Clock Block stack forcibly cancels it. This is not a simple1-second spammable passive.
- Hide Self can be toggled off. Using another ability normally removes Hide, with exceptions for Hide itself and an ItemAbility release. Being hit or collecting an item also removes it. Hide and Jump transfer forced-draw-state ownership so one ending does not accidentally restore the other state.
- Shield has no configured max-hits in the recovered default. Its1.5s timer and specific hit-reason cancellation are client-declared; do not invent a one-hit charge. Reflection changes projectile owner and multiplies base attack by0.8. Pickup Shield instead has bounce=false.
- Teleport freezes its own cooldown while its token exists. Stopping schedules a325ms delay and freezes movement/rotation; during this scheduling window the client cancels collectable pickup and PRE_CURVE_HIT events. Destination legality, wall/trail immunity and server cancellation remain unknown.
- Trigger Bomb permits repeated interactions while moving or untriggered; throwing initially zeroes its cooldown, while the triggering/stopping path reapplies it. The exact press sequence is state-dependent, not a single fire button.
- Power Dash adjusts its multiplier relative to existing speed; its nominal5x is therefore not blindly multiplied by all speed buffs. Its200ms active window cancels PRE_CURVE_DEATH client events. Explosion-radius multiplier4 exists in config; no corresponding explosion behavior was established from the inspected BurstAbility, so do not infer one.
- Laser windup is600ms and active ray80ms, with nominal speed0.3x and turn0.035x while charging (the effect doubles that turn multiplier after windup). Ray collision targets SHIPS; repeated-hit arbitration remains server-dependent. Boomerang is specifically configured to ignore trail curves and survive ship hits; it maintains hit IDs and returns to its owner.
- Per-mode effective differences are preserved per CSV row after group and concrete overrides merge; resolved-initial-cooldown is a derived label for the fallback value, not a source key. Examples: Jump cooldown6000ms becomes6250 in1v1/Classic Teams and7250 inSurvival Teams; Brake5250 becomes5750 in1v1/7500 Survival Teams; Teleport6250 becomes6750 in1v1/9250 Survival Teams. Never apply Classic FFA values globally.

## Static provenance

All offsets are zero-based UTF-8 bytes in installed resources/build/assets/PlatformService-zkTPtK_x.js, SHA256 fcaee093cbf48ccaa625c6a2016ed2f05669276402ebb01eb9eb4d90658ec5d6. Exact per-power literal ranges are in the CSV. Shared source inspections are inert local reads/parser results, anchored to prior REA artifact identity; they are **not fabricated REA semantic findings**. Root investigation supplies any new REA Evidence IDs in00-evidence-index.md. Raw source and parser snapshots stay in ignored private/.

| Local source ID | Scope / byte ranges |
|---|---|
| P01 | ModuleType enum and GetModuleGroup:2960470–2962378 |
| P02 | Default and individual numeric ability declarations; exact per-row byte ranges |
| P03 | Names metadata3280740–3290990; unlock map3290990–3294590; mode blacklist3539355–3540325 |
| P04 | Ability / ActiveAbility5226057–5229700 |
| P05 | Effect stack declarations and timer/state lifecycle5251468–5257718; Curve.addEffect5413968–5414648 |
| P06 | Hide/Hole/cooldown/hook/shield effect handlers5260468–5273718 |
| P07 | Projectile, bullets, homing, boomerang, ShotAbility5340923–5352802 |
| P08 | ItemCollectable / bombs / fevers / teleport / ItemAbility5356668–5377168 |
| P09 | Laser, HideSelf,180, Dash and dispatch factory5377168–5387368 |
| P10 | Equipped-defense composition5406868–5407968; reset/step5409768–5413568 |
| P11 | Collectable owner grace5249205–5250268; PickupCollectable5275168–5282368 |
| P12 | Modifier declarations and bounds3005586–3008236 |
| P13 | Turret control/constants5428468–5434168 |

## Remaining verification

For every entry the live server hit/score outcome, self/team damage, exact multi-hit exclusion, rollback ordering, owner-death persistence and controlled runtime activation remain unknown unless another report explicitly supplies runtime evidence.31 is a verified local factory denominator, not proof all31 are reachable in every mode/account. The pairwise audit in05 distinguishes inspected branches from unknown combinations and proposed tests.
