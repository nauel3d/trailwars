# SNAP ARCADE — living interface specification

Scope: continue 785b54f. Retain the selected mint/paper/navy/coral direction and all 46 previous proposals. Implement Home plus small Customize, Shop and Results demonstrations first; wait for their visual approval before extending the remaining routes. No multiplayer, matchmaking, profile grants, commerce or production bootstrap changes.

## Shared language

Motion has a cause: input, state change, spatial continuity or celebration. Input takes effect immediately; animation never gates a button. Defaults below are Trail Wars hypotheses, not measured Nintendo timings. Typography, outlines and short offset shadows remain consistent across screens.

| Token | Duration | Meaning |
|---|---:|---|
| press | 45 ms | Face depresses 4px; hit rectangle stays fixed |
| release | 120 ms | Short return with restrained overshoot |
| select | 100 ms | Tint/outline transfers; selection is distinct from focus |
| enter | 180 ms | Panel settles by 8px; no whole-screen zoom |
| exit | 100 ms | Cancel previous transition; preserve navigation focus |
| reorder | 300 ms | Stable-ID rows slide to their new ranks |
| settle | 160 ms | One 2px local row accent, then rest |
| confirm | 220 ms | Confirmed check/equipment/ownership emphasis |
| celebrate | 460 ms | At most 8 pooled accents; buttons available throughout |
| warning | 140 ms | Local warning emphasis, no whole-dialog shake |

Reduced motion makes transitions immediate, disables decorative simulation and particles, and retains static identity, selected outlines, truthful state text and final placement. Sound and animation preferences are independent. Muted controls remain understandable.

## Screen coverage

`screen-coverage.json` maps every one of the 46 preserved proposals to a policy; these proposals are not all implemented in this checkpoint.

| Family | Trigger and motion | State and cancellation contract |
|---|---|---|
| Home/navigation | Three moving demo cores, growing bounded trails, obstacle anticipation/turn, occasional crash ring; nav face depresses and next panel settles | Pause when covered, hidden, window-unfocused or reduced-motion; resume without time catch-up. “DEMO” label on simulation and standings |
| Play/controls | Input-specific hint highlights, immediate activation | Existing tutorial contract; no fabricated game modes |
| Queue/countdown | Quiet progress pulse; ready/countdown change once per event | Cancel always available. Stop pending loop on exit; demo data clearly labeled |
| Customize/item details | Selection tint, one preview orbit, equip acknowledgement | Preview ≠ owned ≠ equipped. No tick before confirmation. Sample equip remains local to demo |
| Shop/purchase | Item inspect settles, confirmation opens, pending stable, result highlights once | No real purchase in demo. Uncertain transaction stays uncertain; reconcile rather than replay celebration |
| Profile/standings | Stable-ID rows slide; player's improvement gets brief highlight and placement text | Coalesce newer order; do not remove/recreate rows per update; elimination and final position remain explicit |
| Settings | Toggle thumb travels once; saved label confirms | Reduced motion applies immediately; no animation required to understand value |
| HUD | Small rank shift with no bounce; latest authoritative event wins | No invented authoritative event adapter. Future adapter must validate increasing event sequence. Never obscure steering zones |
| Elimination/spectator | Local OUT tag settles; spectator target crossfades | Preserve arena sightlines and back/leave focus; freeze final placement |
| Victory/defeat/rewards/rematch | Victory core flourish and bounded accents; defeat encourages retry; confirmed rewards reveal together or skip | Never imply unconfirmed payout; preview explicitly says no reward granted; rematch cancels all celebration work |
| Loading/notifications/errors | Small low-frequency loading change; persistent actionable error; stable confirmation | No endless loop audio, harsh buzzer, shaking screen, or disappearing error before user can act |
| Component/motion boards | Normal/focus/press/selected/disabled/loading samples | Same components as Home; workbench scrolling is allowed, Home page scrolling is not |

## Decorative Home simulation

Independent normalized 2D kinematics with three fictitious competitors and a few obstacles. Turn toward safe heading candidates before hitting boundaries, obstacles or older trails; scripted occasional failed avoidance supplies an understandable crash. Fixed simulation step, bounded turn rate, bounded trail history, fixed cores/paths/crash accents; no per-frame hierarchy reconstruction. Core motion/trails update at a capped cadence, standings publish at a lower cadence. Path2D proof first, at most 48 points per competitor, under the engine's limit. If rendering cost or fidelity fails two meaningful tests, test a fixed segment pool or mode-specific sprite illustration instead.

## Leaderboard contract

`setRows(rows, instant?)` takes stable string IDs, names, score, elimination state and optional final rank. Mount options supply self ID, HUD behavior and motion preferences. Deterministic tie order. Move rows, not identity; replacement updates cancel older tweens. Placement feedback is textual as well as colored. Final placement does not bounce repeatedly. HUD mode suppresses flourish. Home uses fixture rows only. Real standings require future authoritative match events; no new server event or invented rank formula in this task.

## Lifecycle and budgets

Shared motion scope owns tweens, completion connections, timers, loops and optional sound voices. A new tween cancels conflicting property ownership. Canceled completion cannot commit stale state. Destroy releases everything. Hidden ancestors/window deactivation suspend loops and settle outstanding tweens; resume never simulates elapsed background time. Resize recomputes normalized coordinates without rebuilding instances. Controller focus is restored after demo navigation. No global UIScale.

Initial bounds to verify: 3 cores, ≤48 trail points/core, 3 standing rows, 8 celebration accents, ≤3 UI audio voices, no ambient crash/hover sound spam. These are design limits, not hardware performance claims. Original synthesized select/confirm/warning cues use short envelopes; no Nintendo sounds or music. Audio upload/availability must be verified separately. No background music in this checkpoint.

## Research applied

[Nintendo Switch Sports developer interview](https://www.nintendo.com/en-gb/News/2022/May/Ask-the-Developer-Vol-5-Nintendo-Switch-Sports-2215553.html): coordinated art, sound and interaction continuity. [Big Brain Academy interview](https://www.nintendo.com/sg/interview/azls/02.html): observe inexperienced players and soften discouraging failure sounds. We infer that Trail Wars should communicate the outcome clearly with small, consistent visual/audio responses; these sources do not establish our durations or retention effects.

[Roblox UI animation](https://create.roblox.com/docs/ui/animation) and [TweenService](https://create.roblox.com/docs/reference/engine/classes/TweenService) provide the native transition mechanism. Explicit scope ownership guards canceled completion and disposal. Actual engine checks remain required for text, safe areas, signal lifetime and Path2D rendering.
