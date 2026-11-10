# TRAIL WARS — working layered premium prototype

**Unapproved, isolated design prototype. No Roblox implementation, merge, publishing, purchases, persistence or gameplay changes.** Existing Candy Comet work and unresolved regression evidence remain preserved. This branch is `design/layered-premium-prototype`.

Open [review.html](review.html) for the live viewport workbench, recordings, actual captures and reference comparison. Open [index.html](index.html) directly for the interactive Home and Shop. This is a real DOM interface with independent artwork, text, button faces, shadows, highlights, category state and modals. Neither previous full-screen Home/Shop PNG is loaded by the prototype.

## Try it

1. Move the mouse on Home: distant, middle and foreground layers move at different smoothed depths. Let go: subtle idle drift and two decorative racers continue. Type, PLAY, menu controls and prices are outside the parallax layers.
2. Hover and hold PLAY or navigation. The target stays put; the face depresses and its shadow compresses. PLAY sends no game request; the actual playable build is unchanged.
3. Open Shop: background dims/blurs; the dialog enters, traps focus and remains keyboard-closeable. Hover a card, select Cores/Trails, inspect Ring Core or Dashed Trail.
4. “Simulate purchase” uses this page's sample balance only. Pending can be canceled without charge. Success changes the item to Owned exactly once; insufficient sample funds show a stable error. Refresh resets the fixture. There is no network purchase/Roblox call or local persistence.
5. Close nested inspection and Shop: focus returns appropriately, old animations cancel and Home resumes. Escape also closes dialogs. Tab/Enter/Space work through native controls.
6. Settings: Reduced motion stops parallax, idle and ambient racers immediately. High/Balanced/Low are independent from reduced motion. Low keeps artwork/state clarity and removes ambient rendering and costly blur. Audio remains silent.
7. On a touch-emulated/real browser, hold the racing-art region for restrained depth response. It does not attach motion to a purchase target or hijack Shop scrolling.

Other Home destinations truthfully disclose that their existing game routes are preserved and not rebuilt here. This gate proves Home, Shop, inspection and preference components; it does not pretend the other screen families are complete.

## Responsive proof

Actual browser screenshots in `qa/`, not regenerated flat screen illustrations:

| Viewport | Home | Shop |
|---|---|---|
| 1920×1080 | Open desktop composition, independent title/art/action regions | Asymmetric four-item showcase |
| 2560×1440 | Bounded layout and larger display/control tokens | Larger but bounded showcase |
| 1366×768 laptop | Shorter header/art, preserved controls | Reduced promotional chrome, bounded content |
| 1440×900 /16:10 | Native reflow with independent dimensions | Same visual hierarchy, content can scroll |
| 768×1024 tablet | Navigation rail + title/hero/action stack | Two columns with readable art/prices |
| 390×844 portrait | Compact brand, illustrated hero, fixed PLAY and two-row navigation | Vertical touch cards; header/tabs/close stay available |
| 844×390 landscape | Dedicated shallow header, left navigation, separate action and hero | Compact paired cards, bounded content scrolling |
| 320×568 small phone | Less secondary copy/decorative area; main actions retained | Promo removed; first product price visible; vertical catalog |

Two additional synthetic safe-area stress cases apply top/bottom 30/20px to the smallest phone and left/right/bottom 40/20/10px to landscape. These are browser stress values, not device certification. CSS uses actual safe-area environment values by default. Home never scrolls. Only bounded Shop content scrolls. No global screen scaling is used.

## Actual motion evidence

- [Desktop interaction recording](qa/desktop-interactions.mp4): normal-speed actual browser capture, including parallax, pressure, modal, inspect, sample purchase, tabs and reduced motion.
- [Phone interaction recording](qa/phone-interactions.mp4): normal-speed Chromium mobile/touch emulation, including an actual touch hold, Shop scrolling, tab and cancellation.
- [Home responsive sheet](qa/home-responsive-sheet.png), [Shop responsive sheet](qa/shop-responsive-sheet.png): unmodified actual captures, scaled only for the sheet. Original PNGs remain beside them.
- [Verification](qa/verification.json), [emulated-touch check](qa/touch-check.json).

Recordings are neither Roblox Studio footage nor generated animations. They do not establish rendered client FPS, physical-phone performance or Roblox implementation fidelity.

## Components and lifecycle

`prototype.css` defines shared button face/base/highlight, card surfaces, type, category tabs, dialogs and responsive layout rules. `prototype.js` supplies atlas sprite views, catalog rendering, cancelable keyed motion, nested focus restoration, sample transaction states and a single Home animation scheduler.

Three original raster assets are separate: distant environmental illustration, four-object transparent racer atlas, eight-object transparent icon atlas. `assets.json` records dimensions, alpha and checksums; `asset-prompts.json` records built-in image-generation prompts. Native editable paths provide the two trail treatments. Explicit sprite clipping prevents neighboring cells bleeding into differently shaped containers. Text and labels are never baked into these sprites.

One RAF scheduler updates only decorative transforms and two cached-path racers. It stops while any dialog is open, on blur/hidden/disposal, under reduced motion or at Low detail. New modal/card transitions cancel the prior keyed animation; no full interface is rebuilt each frame. Category/ownership changes rebuild only their small catalog region using delegated events. Pending cancellation invalidates its generation. Exit clears listeners, RAF, timers and animations.

## What passed, and what remains

Ten layout cases pass checked game-control bounds, viewport containment and modal close visibility. Interaction checks pass: different parallax depth with fixed PLAY position, category filtering and price containment, exactly-once local sample purchase, pending cancellation without charge, insufficient-funds state, focus restoration, eight rapid open/close cycles, reduced-motion stop, Low-tier ambient stop and disposal. Real Chromium touch input moved the decorative spring. Five additional interrupted-entry/exit stress cycles retained exactly 300 DOM nodes before/after; reduced motion interrupted an active entry and Low detail used no transient backdrop blur. The review workbench also retained an open Shop while changing the actual iframe viewport from portrait to landscape. See the JSON for exact evidence; these checks do not certify artistic quality.

Critical visual caveats: the hero is intentionally expressive and large; if that feels oversized, reduce the illustration rather than text/controls. Native trail art is simpler than the richly rendered core. White product information areas are deliberately quieter, influenced by the reference's hierarchy. The exact native Roblox equivalent has not been built or benchmarked. Your visual approval is still required.

Known-working `bbd39c7`, approved slice and pending `7419afd` implementation evidence remain unchanged. The client-Final/winner regression and unusual managed-client render intervals remain unresolved, with no claimed engine cause. No physical-device FPS is claimed.

## Run locally / reproduce

From repository root:

```powershell
python -m http.server 8765 --bind 127.0.0.1 --directory design/layered-premium
```

Then open `http://127.0.0.1:8765/review.html` or `/` for the prototype. This is local preview hosting, not public publishing. It also works as local files except browser-specific iframe readback restrictions.

Node checks use existing Playwright 1.62.1, sharp 0.35.5 and Chrome. Set `TRAILWARS_NODE_MODULES` / `CHROME_PATH` when using another installation:

```powershell
node design/layered-premium/verify.mjs
node design/layered-premium/record.mjs
```

Playwright's FFmpeg dependency is required for recording. MP4 copies were encoded from the original WebMs without speeding up or fabricating motion. Source footage is retained. Private video frames used in the comparison stay local and are git-ignored; another checkout may omit them without affecting the prototype.

[Roblox implementation and performance plan](implementation-plan.md) maps this prototype onto the existing native/Rojo foundation. Do not begin that implementation, merge or publish until the owner explicitly approves the prototypes.
