# Provisional MVP, later work and excluded systems

Reference traversal is still incomplete. This roadmap preserves the audit gate: system foundations and neutral wireframes can be reviewed now; final branding and paid offer selection wait. Proposed requirements below are not a claim of delivery or an approval to publish. See QA and README for actual verified implementation.

## Work sequence and exit gates

| Priority | Owner role | Work / module boundary | Exit evidence | Dependencies / blocker |
| --- | --- | --- | --- | --- |
| P0 | Research | Complete reachable screen queue in `research/01_screen_catalog.md` and navigation graph | Every discovered branch inspected or explicitly blocked; counts reproducible | Authentication, protected/paid flows and unavailable devices may remain blocked. |
| P0 | Systems | Audit `src/server` profile readiness, session ownership, migration and save ordering | Fault injection proves no inaccessible data overwritten; shutdown documented | Connected Studio/test place needed for platform integration. |
| P0 | Economy | Verify receipt replay, cross-server race and atomic durable grant | Duplicate/race/crash tests pass against test adapter and platform boundary | Real configured IDs absent; sales remain disabled. |
| P0 | Client | Finish neutral router, Back/modal/focus and settings draft lifecycle in `src/client` | All TW00–TW09 state transitions matched to source and executed tests | Keyboard/gamepad/touch emulation must be available. |
| P0 | QA | Open a separate test place / built local place; profile memory, frame time and navigation | Recorded baseline and actual test dimensions; error logs reviewed | No user-owned existing place should be overwritten. |
| P1 | UX | Compare three original directions and choose tokens after audit | New-player comprehension and collision-visibility results | Reference closure and representative devices. |
| P1 | Client | Implement final responsive art treatment and small cosmetic previews | 360-pixel narrow layout, desktop and safe areas pass | Approved visual direction; no reference asset copying. |
| P1 | Gameplay | Replace mock contract with authoritative queue/match events | Simulation owns movement/collision/results; UI events cannot forge rewards | Separate future gameplay phase; explicitly outside current final-gameplay scope. |
| P1 | Economy | Decide direct milestones versus single earned currency | First-unlock and comprehension experiments support simplest option | Actual round cadence and anti-AFK eligibility. |
| P2 | Product / economy | Define exact direct permanent appearance offer | Contents, type/ID, local runtime prices and cancellation reviewed | Complete audit; user publishing/commerce approval. |
| P2 | QA | Physical low-end phone and controller pass | Actual device names, metrics and issues recorded | Physical devices not verified in current environment. |

## Proposed launch scope

One overhead survival mode, auto-forward cores, left/right steering, short rounds and clear rematch. Menus: Play, Customize, Shop, Settings; compact profile only. Core and trail appearance ownership, an always-available default, meaningful locked explanation and two-dimensional preview. Server-owned data and commerce plumbing remain separate from per-round state. Match HUD, spectator and results expose their mock status until real events exist.

Settings initially: sound level, reduced motion, readable text option and Controls. Defer advanced graphics until measurement identifies a user-controlled option that matters; Roblox's own settings remain authoritative where applicable. Do not imitate the reference's resolution multipliers, uncapped-FPS restart or multi-player keyboard configuration.

## Later, only after demonstrated demand

Friend invites using Roblox-native flows; simple party queueing with host/roster rules; noncompetitive profile statistics; expanded cosmetics; elimination/result effects with strict visibility budgets; deterministic cosmetic milestones; accessibility remapping if testing requires it. Ranked competition, leaderboards, custom rooms, region selection, replays and match history require validated gameplay, abuse resistance and support capacity before a UI is added.

## Excluded from launch

Paid powers and combat modifiers; purchasable lives; paid random treasures; progression boosters; tier skips; subscription/VIP timers; seasonal obligation loops; multiple paid/earned currencies; ad/video/referral reward panels; external Discord registration; desktop local guest accounts; avatars, hoverboards, humanoid animation and 3D social lobby; betting; user-uploaded avatars and general chat. This is an intentional scope proposal based on the product brief and current evidence, not an assertion that every reference feature was tested.

Store filtering/search is deferred while the catalog fits a small page. Avoid placeholder “coming soon” controls. Deferred systems have no visible inert buttons. If a system is later approved, add its server contract, empty/loading/error states and QA evidence before adding its navigation entry.

## Release gates still required

Audit closure or explicit scoped acceptance of unresolved reference questions; actual Studio runtime verification; profile fault tests; no dead controls; no false multiplayer claim; input/focus checks; measured baseline and regressions; real product metadata/entitlement tests before commerce; final art/branding selection; separate approval for publishing or charging. Physical-device tests must remain marked blocked until performed.
