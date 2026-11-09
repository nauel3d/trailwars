# Complete UI inventory and state coverage

Status: design proposal for owner approval, 2026-11-09. Nothing in this plan enables gameplay, production data or paid purchases. The approved MAKE IT YOURS PNG anchors appearance, not every route's layout. Source audit: App.luau, Widgets.luau, Peach*.luau, Catalog, ProfileSchema, Contracts, Config, ProfileStore, EconomyService, PurchaseService and fourteen existing stories.

## Status definitions

**E** existing behavior in main's UI/data foundation; **V** preserved visual experiment, unapproved; **M** explicit mock only; **P** proposed client/UI work after approval; **I** requires future authoritative integration, not implementation in this assignment; **L** later; **X** excluded. A launch need is not a claim that it works today.

## Route and panel inventory

| ID / area | Existing baseline | Complete meaningful states | Plan / disposition |
|---|---|---|---|
| ENT-01 Boot | E: App mounts and requests Snapshot; no dedicated boot route | starting, critical art loading, missing art fallback, profile loading, ready | P MVP: short logo/status scene; no click-to-enter welcome |
| ENT-02 Profile connection | E: Snapshot with loading/busy/recovery gates | waiting, confirmed, last-known stale, failed read, session leased, incompatible schema, service unavailable, retry pending, retry failed | P MVP: visible recovery sheet; balance/owned status never fabricated |
| ENT-03 First use | E: Play always visits Tutorial | session controls unseen, learning, dismissed, returning in same session | P: session-level skip. Cross-session completion requires an approved preference contract; cannot infer first launch from zero XP |
| HOM-01 Home | E route; V skins/fit experiments | connected, loading profile, offline/read-only, reconnecting, notification, input changed | P MVP: one screen, one dominant Play, core/trail identity, four secondary destinations; no page scroll |
| HOM-02 Profile access | E route/link | readable long name, zero stats, last confirmed stats | P: compact identity panel, no avatar body or rank |
| PLY-01 Controls | E keyboard/touch/D-pad intent preview | keyboard, controller, touch, input switch, simultaneous left/right, focus loss, controller disconnected | P MVP: three rules, two steering controls, Continue; review from Settings |
| PLY-02 Quick Play | M: Demo/Queue progression only | entering, searching, cancel requested, canceled, failed, retrying, unavailable | P presentation; I queue adapter. No mode-selection page |
| PLY-03 Match found | M countdown | match found, joining, join failed, lobby lost, countdown 3/2/1, cancel no longer valid | P/M; I real session. No redundant Ready button unless backend later needs one |
| HUD-01 Match HUD | M static arena and control intent | active, last two, player identified, survivor update, elapsed time known/unknown, announcement, round ending | P visual contract; I authoritative event/clock. Timer is elapsed time, not a new hard round limit |
| HUD-02 Pause / leave | E immediate Home navigation | overlay open, keep playing, confirm leave, leave pending/failed, disconnected | P MVP dialog; online game continues while menu open. Never imply multiplayer is paused |
| ELI-01 Elimination | M combined spectator text | collision acknowledgment, placement known/unknown, brief handoff, interrupted by results | P/M; I placement. Gentle acknowledgment, no shaming buzzer or paid revive |
| SPC-01 Spectator | M static scene | observing, no survivor available, round ending, results ready, connection lost, leaving | P/M. Switching target is I/L until roster/camera contract exists; no fake working arrows |
| RES-01 Victory | M generic Results | confirmed winner, placement, statistics available/unavailable, rewards pending, continue | P dedicated winning composition; no fabricated reward amounts |
| RES-02 Defeat | M generic Results | confirmed placement, missing placement, reward pending, rematch, Home | P: calm, optimistic, same actions as victory |
| RES-03 Rewards | E server reward/receipt foundations; no client grant or match reward feed | authoritative receipt not yet available, confirmed deltas, delayed confirmation, failed refresh, replayed acknowledgment | P/M presentation; I settlement data. Rematch does not depend on an invented payout |
| CUS-01 Collection | E Catalog and ownership/equip; V approved-art experiment | core/trail tab, all/owned, selected, owned, locked, equipped, unavailable, empty category, loading, stale profile | P MVP: categories only Core and Trail. Default four-item catalog |
| CUS-02 Preview | E simple visual; V separate art layers | starter/ring core, continuous/dashed cosmetic trail, not loaded, art fallback | P: same collision boundary; all selection feedback local until equip confirmed |
| ITM-01 Details | E full-page modal-like route | owned unequipped, equipped, locked affordable, insufficient coins, no profile, off-sale | P real overlay/sheet with parent preserved |
| ITM-02 Equip | E Equip action | ready, submitting, confirmed, rejected, transport failure, late response, reconciliation required | P UI treatment; retain authoritative snapshot and write barriers |
| ITM-03 Unequip | no Unequip action | reset to starter, starter already selected, reset pending/failed | P UI uses existing Equip(default item); never an empty core slot |
| SHP-01 Shop | E earnable items; V shares experimental Customize view | browsing, core/trail category, selected, owned, available, unavailable, empty, loading, profile missing | P MVP: two earnable offers; no Featured tab for two products |
| SHP-02 Affordability | E balance/cost checked on server | affordable, insufficient, price changed/unavailable, balance stale | P: clear cost + confirmed balance; disable confirm when ineligible |
| PUR-01 Confirm earned purchase | E BuyEarned confirmation | open, cancel before submit, confirm, duplicate activation blocked | P centered dialog / phone sheet. Exact item/cost/remaining balance from known snapshot |
| PUR-02 Processing | E pending guard and 15s watchdog | submitting, server busy, success, business rejection, network failure, timed-out unknown | P explicit state; success only after server confirmation |
| PUR-03 Unknown outcome | E needsReconciliation + unresolvedWrites; late replies gated | unknown, still processing, refresh pending, stale refresh blocked, confirmed owned, confirmed not bought, refresh failed | P persistent recovery message. Never offer a second charge until reconciliation |
| PUR-04 Paid commerce | E receipt foundations, Config closed | unavailable, future metadata loading, native prompt canceled, grant pending, verified entitlement | MVP unavailable only. All live paid screens I/L and gated by separate approval |
| PRO-01 Profile | E coins/XP/rounds/wins; no levels | confirmed, zero-history, loading, stale, missing, long name | P MVP: core identity, wins, rounds, total XP. No invented level, next-tier XP or history |
| PRO-02 Rewards / achievements | no badge/achievement UI contract | no supported feed | L after product validation; no decorative achievement grids |
| SET-01 Audio | E SetSetting music/sound, assets not yet integrated | 0–100%, mute, saving, confirmed, rejected, offline | P sliders use existing validated values. Do not claim audio exists before sound assets integrate |
| SET-02 Controls | E review Tutorial + intent | hardware-specific hints, input changed, disconnect | P panel; remapping and adjustable steering zones L, not fake sliders |
| SET-03 Accessibility | E textScale 1–1.5 and reducedMotion | 100/125/150%, enlarged wrapping, engine preference, reduced motion on/off, save error | P MVP. Honor platform preferences as well as explicit local choice |
| SET-04 Restore defaults | no atomic batch-setting action | confirm, sequential field saves, partial success, retry remaining, complete | P optional MVP if owner approves; honest partial-save handling; no backend rewrite |
| SET-05 Graphics | no meaningful supported settings | not applicable to this UI-only build | X from MVP. No fake FPS/quality/fullscreen controls |
| SHR-01 Dialog | E full-page modal rendering | open, focused, nested confirm, disabled parent, busy, close, parent restoration | P reusable overlay; one top modal active, max depth 2 |
| SHR-02 Notification | E message string | info, success, warning, actionable persistent error | P one message area; max 2 passive toasts; never obscure Play or controls |
| SHR-03 Help / tooltip | E control hints only | pointer hover, focus help, touch tap information, dismissed | P short inline help; no hover-only instruction |
| SHR-04 Connectivity | E request failure and retry | transient disconnect, retry, missing service, late result, server closing | P durable banner/recovery sheet; I match rejoin, never fake a rejoin button |

## Explicit product decisions

**Launch UI:** entry/recovery, Home, short controls, single Quick Play queue, countdown, HUD plan, elimination/spectator/results, four-item collection, two-item earnable shop, profile and existing settings, shared dialogs and purchase recovery.

**Later:** social/party invite, actual spectator cycling, achievements, session history, persistent tutorial acknowledgment, new cosmetic categories, optional direct paid cosmetics, remappable controls, configurable mobile steering. These require validated value and appropriate contracts.

**Excluded:** mandatory welcome splash, 3D lobby, humanoid/avatar body display, ranked/multiple modes, battle pass, daily-reward calendar, gems, paid random items, paid abilities/revives, timed discounts, XP boosts, artificial notifications, fabricated online counts. Daily rewards are absent because no grant contract or validated need exists.

## Contract boundaries

Current public actions are exactly Snapshot, Equip, BuyEarned and SetSetting. MatchEvent has kind, matchId, isMock and optional remaining/winnerUserId. It does not supply an authoritative elapsed clock, placement, reward deltas, observed-player roster or join/queue request API. Mockup-only presentations of those states are explicitly marked. Their future fields are integration proposals, not changes to Contracts or server systems.

Profile exposes coins, XP, owned IDs, equipped core/trail, music/sound/reducedMotion/textScale, rounds and wins. Private receipts, reward ledgers and lease metadata stay private. All examples in the presentation are labeled sample/mock data. No visible number is evidence of conversion, retention or a live player's achievements.
