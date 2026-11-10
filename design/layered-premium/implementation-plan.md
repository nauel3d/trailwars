# Roblox implementation / performance plan — approval required

This is a future native implementation plan, not code deployed to Studio. The interactive browser prototype proves composition, layering and interaction intent. It does not prove native Roblox rendering cost, fidelity or physical-device performance.

## Preserve the game

Keep the existing native Luau/Rojo modules, UI Labs, native input, authoritative snapshots, round/scoring/statistics systems and fallback `bbd39c7`. No framework migration, full rebuild, multiplayer rewrite, new shop economy, sound upload or 3D vehicle migration. Diagnose the carried client-Final/winner regression as a separately tracked release blocker in the next authorized implementation phase; these designs do not fix it.

## Reusable component mapping

| Prototype part | Native counterpart / contract |
|---|---|
| Gloss button | Stationary TextButton/ImageButton hit target; separate base, face, native text/icon and upper highlight; one keyed press/release tween; explicit disabled/focus/selected states |
| Atlas sprite | Individual ImageLabels with ImageRectOffset/ImageRectSize or separately exported transparent PNGs; aspect constraint; crop/padding validation at every intended size |
| Outlined text | Native Fredoka One short labels/display type, measured text, controlled UIStroke and one offset shadow; readable body face and constraints for long content |
| Material panel | Frame/UIGradient/UIStroke where sufficient; authored 9-slice images for distinctive edge/bevels that native geometry cannot match efficiently; text remains independent |
| Shop card | Native art region + distinct label/description/action region; shared selection/hover scope; one selected preview, no ViewportFrame grid |
| Modal | Overlay scope, bounded dim/optional blur, header/close, native focus navigation and origin-focus restoration; input available while decoration settles |
| Parallax scene | Three independent decorative containers plus cached sprite positions; one spring controller; no text/control children in moving containers |
| Catalog / transaction UI | Existing actual catalog and authoritative service results. Browser-local fixture must never be copied as a production purchase implementation |

Current art atlases contain four racer objects and eight icons with true transparency. Native export must handle the odd icon-atlas dimensions with integer-safe cropping/padding and edge extrusion; the browser's explicit clip fix is not an excuse to ignore native bleed. Keep transparent margins. The large Home racer is promotional art, not a new hitbox, collision radius, steering model or camera direction.

## Layout rules and safe areas

Use the actual usable rectangle from existing GuiService/safe-area helpers. Account for cutouts, top bar, home indicator and controller/TV overscan. Layout by available width **and height**; use component size bounds, aspect constraints and content measurement. No single global UIScale. UI Labs stories should cover 1920×1080, 2560×1440, 1366×768, 1440×900, tablet, portrait, compact landscape and 320px phone with text-size variations.

Desktop Home has independent navigation/title/action/art regions; tablet stacks title/art/action beside navigation; portrait uses a shorter hero plus fixed PLAY/two-row navigation; compact landscape has a shallow header and an independent action/art split. Reduce secondary copy and artwork first on small safe areas. Home must never page-scroll.

Desktop Shop uses the asymmetric showcase. Tablet uses two columns. Portrait uses vertical cards with 48px primary actions and persistent header/tab/close. Compact landscape uses compact paired cards. Only the product region may scroll. Ensure a category change cannot clip action controls, as the laptop prototype review exposed. Long names/localization and preferred text size must not silently shrink important text into unreadability.

Active match presentation keeps **1300:800** world geometry and the proven steering/power controls. Menu artwork can be expressive; it is never a reason to enlarge lethal geometry, obscure trails, add decorative world obstacles or distort the arena.

## Motion tokens and cancellation

These are original targets demonstrated in the browser, not measured reference-game timings:

| Trigger | Proposed native motion | Interruption / reduced motion |
|---|---|---|
| Hover / focus | Face highlight ≤12%; persistent distinct focus edge | No audio spam or moving hit target; reduced motion retains tint/focus |
| Press | 65ms face depression 5px, lower shadow compression | Action dispatches immediately; pointer cancel/focus loss releases |
| Release | 125ms restrained return | Replace prior keyed tween, no accumulating bounce |
| Shop open | 210ms /24px settle, scale .965→1, dim/blur | Close usable immediately; newest generation wins; reduced motion jumps to state |
| Shop close | 130ms /12px, scale 1→.98 | Cancel previous entry, restore originating focus, stop blur and modal callbacks |
| Category | 160ms, one 8px region settle | Cancel old category transition; preserve valid selection/focus |
| Card hover | Art ≤3.5% and ≤2°; subtle rim glow | Fixed target, no perpetual card animation; reduced motion uses border only |
| Confirmed result | One 260ms art settle and readable state | Only after authoritative confirmation; no inferred purchase/kill/reward |

Separate spring controller for decorative parallax: approximate stiffness 125, velocity decay exp(-15×dt), bounded dt. Desired pointer amplitudes 4px distant /10px middle /18px foreground, plus small idle ≤3.3px on the foreground. Phone amplitude about 42% and touch-art-region only; no gyroscope permission or scroll hijack. Important text, purchase targets, live standings and power controls never move in parallax. Controller input may leave the scene neutral rather than inventing constant focus-driven motion.

Scope every animation/listener/timer by screen/round/generation. Cancel on screen exit, hidden/occluded state, reset, rematch, respawn and destruction. One Home scheduler, not one RenderStepped connection per icon. Frozen cached geometry stays unchanged. Reduced motion applies immediately and is independent of quality and mute.

## Applying the approved language to the remaining families

These are planned contracts, not screens implemented in this prototype:

| Family | Reuse / restraint |
|---|---|
| Customize | Same inspection stage, separate core/trail artwork and explicit preview/owned/equipped; selection art tilt once, not an always-spinning grid |
| Profile | Same header typography and pilot icon; truthful wins/kills/deaths/hits/time grouped for reading; no fake rank/pass system |
| Settings | Same toggle/select/close materials; reduced motion immediate, quality separate; no invented playing music |
| Countdown | Native outlined numerals, crisp GO; minimal occlusion, no menu parallax over the arena |
| Powers / HUD | Quiet compact chrome; original Homing/Jump icons; fixed hit targets, actual cooldown numbers/progress; press feedback shorter than competition events |
| Elimination / turret | Immediate OUT/rocket instruction from authoritative state; original rocket icon; no animation delay in steerability |
| Inter-round standings | Existing stable-ID rows, previous/delta/final score, smooth reorder and one local improvement accent; live play much quieter |
| Final results / rematch | Larger original winner art and bounded celebration after the round; cancel all old final work on rematch; never replay stale network effects |
| Loading / notices / errors | Same readable modal grammar, clear pending/cancel/retry; persistent error until actionable; no false success |

## Detail tiers / low-end strategy

| Tier | Presentation |
|---|---|
| High | Three decorative depths, two bounded sample racers, static atlas art, optional blur during modal only |
| Balanced | Same readable art/content; sample-racer updates at half cadence, fewer secondary accents, smaller blur |
| Low | Same silhouettes, text and action clarity; no ambient/parallax scheduler, simple dim instead of blur, essential event-driven feedback only |

Reduced motion is not “Low quality”: it independently removes travel/idle/bounce at every tier. No tier changes actual match visibility, geometry, collision or authoritative information. Avoid automatic switching without real device evidence.

Three decoded RGBA textures at current dimensions are roughly **18 MiB total** before engine overhead/mips/copies. That is a dimension-based planning estimate, not measured GPU memory. Production may use different exports/resolutions. Reuse texture references; do not upload huge full-screen interface skins. Dynamic full-screen blur and overlapping transparency are the largest likely menu risks. Prefer a cached/preblurred decorative background or bounded blur if native profiling shows a cost. The browser proof is not a promise that native blur is cheap.

## Native acceptance gates after explicit approval

1. Implement one button/card/modal/scene slice in UI Labs and the isolated integrated place. Compare actual Studio capture and recorded motion to this working prototype and the supplied benchmark, rather than declaring fidelity from static source tests.
2. Verify keyboard/touch/controller focus, pressed cancellation, backdrop close, category changes, pending/cancel/error/confirmed states and reduced motion. Production ownership/balance comes only from existing services. No live purchases during testing.
3. Keep the existing gameplay tests and CI. Run a clean normal visible-client sample and a real two-client Home→match→three-round Final→rematch regression, including Homing, Jump, rockets, stats and event dedup. The pending client-Final failure remains a blocker until truly fixed/tested.
4. Profile comparable scenes before/after: rendered client intervals mean/p95, relevant UI/script timing, GUI/Path2D counts, active tweens/connections, atlas/texture memory where accessible and cleanup after repeated screen/round cycles. Do not use server CPU as client FPS or browser measurements as Roblox performance.
5. Target at most one scene scheduler, two menu racers, three decorative containers and a small fixed number of event effects. Repeated open/close and reset should return objects/connections/tweens to baseline. No hidden-scene loops, indefinite animation queues or full GUI rebuild per frame.
6. Check actual low-end phones/tablets where available. Emulated viewport/touch evidence is not physical-device certification. Preserve the existing unresolved managed-client render investigation without inventing an engine/scheduler cause.

Official feasibility references already reviewed in the preceding design phase: [cross-platform](https://create.roblox.com/docs/projects/cross-platform), [position/size and reserved zones](https://create.roblox.com/docs/ui/position-and-size), [accessibility/preferences](https://create.roblox.com/docs/production/publishing/accessibility), [9-slice](https://create.roblox.com/docs/ui/9-slice), [Font enum](https://create.roblox.com/docs/reference/engine/enums/Font), [Path2D](https://create.roblox.com/docs/reference/engine/classes/Path2D).

No publishing, merge, sound upload, production data or game replacement is authorized by this plan or by passing browser checks.
