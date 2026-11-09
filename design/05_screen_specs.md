# Responsive launch-screen specifications

**PROVISIONAL design contract, not an executed-results report.** The reference audit and final art selection remain open. These neutral wireframes are original compositions. Implementation coverage must be checked against actual source and `qa/executed_results.md`; listed states are requirements, not claims they all work today. Desktop example assumes 1280×720 available content; narrow example assumes 360×640 before safe-area adjustment. Validate both portrait menus and landscape play.

Common acceptance rules: all primary controls at least 48 logical pixels high; text wraps without overlap; modal focus is contained and restored; keyboard/gamepad Back has the same meaning as visible Back; touch never depends on hover; reduced motion removes transitions; repeated activation submits once. Network response times have no invented performance claims. Local request IDs discard stale responses. State is announced in visible text as well as any animation.

## TW00 — Entry and data recovery

Route: client initialization, before Home. Data: profile status, migration outcome, connection state. Copy: “Preparing your trail…”; after failure, “Your data couldn't be loaded. Try again.”

```text
Desktop                         Narrow mobile
+----------------------------+  +------------------+
|          TRAIL WARS         |  |    TRAIL WARS    |
|   Preparing your trail...   |  | Preparing your   |
|       [status text]        |  | trail...         |
| [Retry, when appropriate]  |  | [Retry]          |
+----------------------------+  +------------------+
```

States: loading; migration running; loaded→Home; failed read; locked session; disconnected; retry in progress; incompatible newer schema. No balance, owned badge or purchase button appears before authoritative load. Retry retains no fake inventory. Incompatible data shows “This version can't load your profile” and an honest unavailable state rather than rewriting data.

Focus begins on Retry only when actionable. Cancel means leave the retry attempt, not erase data. No continuous decorative animation; static status works. Security boundary: server owns defaults, migrations and readiness. Acceptance: injected read failure produces no overwrite; two retries do not create competing profiles; success enters Home once.

## TW01 — Home and compact profile

Route: loaded entry or any Home action. Data: display name and authoritative equipped appearance; optional saved settings.

```text
Desktop                              Narrow mobile
+---------------------------------+  +-------------------+
| TRAIL WARS             [Profile] |  | TRAIL WARS [Profile]|
| Steer left or right...           |  | Steer left or right.|
|                                 |  | Your trail is a wall.|
| [ PLAY ]   [core + trail sample] |  | [core sample]     |
| [Customize] [Shop] [Settings]    |  | [ PLAY ]          |
| Mock flow / data status         |  | [Customize] [Shop]|
+---------------------------------+  | [Settings]        |
                                     | Mock flow status  |
                                     +-------------------+
```

Play opens Controls on first use, then mock queue. Customize, Shop and Settings navigate locally. Profile opens a small panel with display name, equipped item and server-confirmed statistics when available; missing stats say “No completed rounds yet.” Never show fabricated wins. Profile Close returns focus to its opener.

States: ready; profile read-only due save failure; profile panel; reconnecting; mock mode badge; production service unavailable. Loading a secondary screen keeps Home available. No external video, event carousel, countdown offer or social-registration banner.

Primary focus: Play. Navigation proceeds through secondary actions then profile. Pressing Play twice creates one queue ticket. Animation: optional short panel fade, no spinning core loop required. Security: profile text is escaped and ownership comes from server snapshot. Acceptance: every visible control routes or explains availability; Home cannot grant progress; empty profile stays readable.

## TW02 — Controls tutorial

Route: Home→Play first use, or Settings→Controls. Data: active input type and tutorial preference.

```text
Desktop                              Narrow mobile
+---------------------------------+  +------------------+
| [Back] How to steer              |  | [Back] Controls  |
| Hold [A / <-]   Hold [D / ->]    |  | Auto-move forward|
|   left            right         |  | [ LEFT ][ RIGHT ]|
| Release both to go straight.     |  | Release: straight|
| Your trail becomes a wall.      |  | Avoid every trail|
| [Show before Play: On] [Continue]| | [Continue]       |
+---------------------------------+  +------------------+
```

States: keyboard, touch, gamepad, input changed, device disconnected, tutorial skip setting saving/failed. The text stays present even if visualization is absent. Continue is explicit; no quiz or forced purchase. Back returns to invoking route. In production, viewing this page grants no reward.

Focus order: Back, preference, Continue; illustration is not focusable. Touch steering examples can respond locally but are labeled demonstration. Animation respects reduced motion. Security: tutorial completion is a preference, never proof of match completion. Acceptance: a new player explains hold/release without prompting; focus loss releases demonstrations; controller unplug switches the labels gracefully.

## TW03 — Queue and connection states

Route: Controls→Continue or returning-player Play. Data: mock harness now; future server queue ticket later.

```text
Desktop                              Narrow mobile
+---------------------------------+  +------------------+
| Mock queue                      |  | Mock queue       |
| No multiplayer match is running.|  | No multiplayer   |
| Waiting for mock match event... |  | match is running.|
| [Cancel]                        |  | Waiting...       |
| [Advance mock — Studio only]    |  | [Cancel]         |
+---------------------------------+  +------------------+
```

States: requesting, queued, canceling, canceled→Home, timeout, service unavailable, connection lost, late-start ignored after cancel. Timeout copy: “Couldn't start a round. Try again or return home.” Production must have no fake player count or estimated wait. Mock-only controls are gated by mode and labeled.

Cancel receives initial focus; it stays reachable during loading. Back is Cancel. Queue animation is unnecessary. Security: server or harness produces ticket/phase events; client cannot assert acceptance. Acceptance: cancel/start race has one outcome; duplicate Play produces one request; timeout Retry doesn't reuse a canceled ticket.

## TW04 — Customize, ownership and preview

Route: Home→Customize. Data: catalog, owned IDs, equipped IDs, profile readiness. MVP categories are Core and Trail only; effect/profile categories remain deferred.

```text
Desktop                               Narrow mobile
+----------------------------------+  +------------------+
| [Back] Customize   [Core] [Trail] |  |[Back] Customize  |
| [Owned item] [Locked item]        |  |[Core] [Trail]    |
| [Owned item] [Owned item]         |  |[preview sample] |
| Selected name  [2D preview]       |  |Selected name    |
| Owned / Equipped / How to earn   |  |[Owned][Locked]   |
| [Equip] [Preview motion On/Off]   |  |[Equip]          |
+----------------------------------+  +------------------+
```

Cards show owned/locked/equipped text. Select opens details in the same page; Equip submits only an owned compatible item. Locked item explains how to earn or opens exact Shop detail if commerce is configured. Preview changes no persistent equip state. Static two-dimensional fallback is the default on weak devices; no heavy ViewportFrame required.

States: catalog loading; owned/equipped; none owned beyond default; locked; preview unavailable; equip pending; rejected ownership; save unavailable; filter empty if a later filter exists. Launch catalog is small, so search is omitted until measured need. One equipped core and one trail replace reference priority slots.

Focus begins on selected equipped card; moving focus never equips. Modal item detail closes to same card and scroll position. Animation is opt-in preview only. Security: server allowlists IDs/type and checks ownership; request contains no price or invented ownership. Acceptance: forged ID rejected; double Equip harmless; unreadied profile cannot equip; default always visible; preview footprint matches gameplay rules when gameplay exists.

## TW05 — Shop and item detail

Route: Home→Shop, or a locked cosmetic's exact item link. Data: catalog and eligibility; runtime product info only when integration is enabled.

```text
Desktop                               Narrow mobile
+----------------------------------+  +------------------+
| [Back] Shop — appearances only    |  |[Back] Shop       |
| [Item card] [Item card] [Item]    |  |Appearances only  |
| No change to speed or collision. |  |[Item] [Item]     |
| Selected: name   [2D preview]     |  |[preview]         |
| Ownership / unlock method        |  |name + unlock     |
| [View unlock] [Close details]     |  |[View unlock]     |
+----------------------------------+  +------------------+
```

States: loading catalog, no items available, owned, earnable, paid metadata loading, live price loaded, price fetch failed, offsale, disabled/unconfigured commerce, stale catalog, platform unavailable. Disabled state copy: “Purchases aren't configured in this build.” There is no substitute Robux number. Paid item action stays disabled until valid configuration and local-player price metadata succeed. No urgency badges or bundles selected before audit closure.

Detail lists exact appearance contents, permanent/consumable nature, and equip scope; it shows no gameplay advantage. Owned items offer Customize, not another purchase. Back closes details before exiting Shop. Focus: selected card→detail close→primary action. Security: display price is informational; server receipt grants according to mapped product ID, not client price. Acceptance: metadata failure cannot open prompt; local preview doesn't imply ownership; returning from details preserves scroll.

## TW06 — Confirm, cancellation and purchase reconciliation

Route: exact item action. Data: earnable server transaction or Roblox platform prompt plus server entitlement.

```text
Desktop                               Narrow mobile
+----------------------------------+  +------------------+
| Unlock [item name]?               |  |Unlock [name]?    |
| Cost / current earned balance     |  |Cost and balance  |
| You receive: exact appearance     |  |Exact contents    |
| [Cancel] [Confirm unlock]         |  |[Cancel]          |
| Status / error + Retry when safe  |  |[Confirm unlock]  |
+----------------------------------+  +------------------+
```

Earned-currency states: confirming; insufficient funds with “Earn more by playing” explanation; pending; granted; failed; uncertain persistence; already owned; catalog changed. Do not auto-open a currency purchase upsell. Paid states: metadata loading→Roblox prompt→closed/canceled or awaiting entitlement→granted; delayed status remains “Purchase received; checking your item” only if receipt receipt-status is actually known, otherwise “Checking purchase status.” Never claim payment receipt from client closure alone.

Cancel has initial focus to prevent accidental spending; confirm is explicit and submitted once. Cancel before request has zero mutation. After a submitted paid purchase, Close only dismisses this interface; it does not imply reversal. Pending grant can reconcile after rejoin. Grant confirmation offers Equip and Continue browsing; no automatic repeat purchase.

Security: earned spending and ownership update atomically server-side; developer-product receipt and durable benefit are committed with replay protection. Acceptance: identical receipt yields one grant; unavailable datastore yields pending/retry, never false success; simultaneous servers cannot duplicate a grant; spoofed prompt-finished event has no effect. Paid prompt itself remains Roblox-owned and its layout is not recreated.

## TW07 — Settings and unsaved draft

Route: Home→Settings; mock HUD menu can open the same route with match context preserved. Data: accepted server settings and local draft.

```text
Desktop                               Narrow mobile
+----------------------------------+  +------------------+
| [Back] Settings                   |  |[Back] Settings   |
| Sound [slider + number]           |  |Sound [value]     |
| Reduced motion [On/Off]           |  |Reduced motion [ ]|
| Large text [On/Off]               |  |Large text [ ]    |
| Controls [View]                   |  |[Controls]        |
| [Cancel] [Save]  status           |  |[Cancel] [Save]   |
+----------------------------------+  +------------------+
```

States: loaded, dirty, save pending, saved, failed save retaining draft, invalid value rejected, reset confirmation if reset exists, read-only during profile failure. Back with dirty draft asks “Discard your changes?” with Keep editing/Discard. Save Close only follows accepted save; failure leaves recovery visible. No privacy/account/Roblox graphics control duplication.

Slider supports keyboard steps and explicit numeric display; controls tutorial is reachable. Sound preview never surprises the user with a loud test. Reduced motion applies immediately to menu preview then reverts on Cancel. Security: server validates settings types, finite ranges and allowlisted fields; no arbitrary attributes. Acceptance: NaN/out-of-range/unknown key rejected; failed save doesn't lose draft; reconnect does not replace newer settings with stale local draft.

## TW08 — Mock HUD, menu and disconnection

Route: queue's mock event now; future authenticated match start later. Data: typed match ID/phase, timer, survivor count, own state, input context. No live multiplayer claim.

```text
Desktop                               Narrow landscape play
+----------------------------------+  +---------------------------+
| MOCK 00:45  4 remaining   [Menu] |  |MOCK 00:45 4 left [Menu]   |
|                                  |  |       overhead arena      |
|       overhead arena placeholder |  |[HOLD LEFT]  [HOLD RIGHT]  |
| A / <- left    D / -> right      |  +---------------------------+
+----------------------------------+
```

States: countdown, active, input suppressed by modal, connection lost, reconnecting, match unavailable, eliminated transition, round ended. HUD does not display powers, cooldowns, fake opponents or fabricated score. Menu offers Controls, Settings and Leave; Leave asks confirmation and explains the current mock context. Real competitive state must continue authoritatively while a menu is open.

Touch holds, keyboard down/up and gamepad axis all feed intent contract; release on focus loss and modal open. Pause overlay must not suggest the server simulation paused. Motion derives from future simulation, not ornamental GUI movement. Acceptance: frame updates change labels only as needed; stale match ID events ignored; menu focus cannot steer accidentally; disconnected display clears held intent.

## TW09 — Spectator and results

Routes: mock elimination→spectator; mock round-end→results. Data: authoritative/harness participant roster, placement, validated reward record and save status.

```text
Desktop spectator / results            Narrow mobile results
+----------------------------------+  +------------------+
| MOCK — You're out this round     |  |MOCK — Round over |
| Watching [core name] [Prev][Next] |  |Placement: #3     |
| [Home]  Waiting for round end    |  |Rewards: saving  |
| ---- after round ends ---------- |  |or confirmed data |
| Placement / rewards save state   |  |[Rematch]        |
| [Rematch] [Home]                 |  |[Home]           |
+----------------------------------+  +------------------+
```

Spectator states: surviving target, target eliminated→next valid target, no targets→await result, disconnection, leave confirmation. Prev/Next disabled with explanation when no target exists. Results states: loading, confirmed result, reward saving, reward save delayed, failure/retry reconciliation, rematch requested, rematch canceled, no completed result. “Mock result — rewards are not earned” must be prominent for harness events.

Focus defaults to Rematch on results and Home on empty spectator. No forced spectating dead-end; no paid revive. Results celebration is short and suppressed by reduced motion. Security: client never awards wins/XP/currency; result ID makes server grant idempotent; rematch is another queue request. Acceptance: duplicate round-end event grants once; missing result doesn't fabricate values; Home remains available during reward reconciliation; disconnect/rejoin restores actual grant status.

## State coverage and test boundary

These specs cover intended launch screens TW00–TW09 plus modal/profile substates. They intentionally separate an **implementation requirement**, a **mock state demonstration**, a **Studio emulation test**, and a **physical-device result**. Only `qa/executed_results.md` can establish what was executed. Final release requires executing these state tests against real services and future authoritative gameplay, then updating the specs to match final implementation rather than leaving aspirational controls visible.
