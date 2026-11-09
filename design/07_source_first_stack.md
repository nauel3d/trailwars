# Code-first UI decision — issue #1

Chosen: native componentized Luau Instances, Rojo 7.7.0, scoped widget lifecycle, injected preview transport, and UI Labs function stories. The existing 29 passing foundation assertions remain the baseline. No reference UI or asset is required to author screens.

| Option | Strength | Cost for this project | Decision |
|---|---|---|---|
| Native Luau components | Existing code; direct control over Instances, event cleanup and TweenService; no runtime dependency | Must implement explicit state, disposal and updates | KEEP; extract App.mount and reusable widgets |
| Fusion 0.3 | Reactive values/computations, scoped cleanup, tween/spring primitives | New dependency and migration; helpful when independently changing state grows | LATER if profiling/complexity justifies |
| React-Lua | Declarative component composition, bindings and reconciliation | Adds framework/runtime/build setup to a small existing tree | LATER for a larger team/component ecosystem |
| UI Labs | Hot reload and sandboxed previews in edit mode; native function stories supported | Requires Studio plugin once; does not replace engine/device validation | Optional development-only preview surface |

This is a practical migration-cost decision, not an unmeasured claim that native Instances outperform either framework. Menu trees rebuild only on discrete navigation or confirmed data updates. No render-loop UI construction, blur, video backgrounds or external UI assets are needed.

UI Labs stories mount the same App and widgets as the game, inject explicit mock fixtures, and return cleanup. They do not call live remotes, require a player, grant inventory, or install a framework. Preview balance is labeled mock. The production Rojo project excludes story fixtures.

CLI loop: edit → format → lint → headless tests → Rojo build → coherent commit. Preserve already-passed checks until code changes justify rerunning them. Studio is reserved for one bundled desktop/mobile/tablet/controller checkpoint after source UI is substantially complete. Further high-cost reference exploration requires a specific blocking question and user approval.

Primary sources reviewed 2026-11-09: [Rojo workflow](https://rojo.space/docs/v7/), [Fusion 0.3](https://elttob.uk/Fusion/0.3/), [React-Lua repository](https://github.com/Roblox/react-luau), [UI Labs function stories](https://ui-labs.luau.page/docs/stories/function), [UI Labs installation](https://ui-labs.luau.page/docs/installation). UI Labs is a Studio preview tool; it does not render Roblox UI in an external browser.

# Original visual direction

Issue #1 supersedes the earlier exhaustive-audit gate. Existing evidence is sufficient to choose Course markings for implementation, while research unknowns stay documented. Alternatives retained: Cut-paper arena (more layers and collision ambiguity), Signal instruments (fine strokes and technical tone). Course markings best fits immediate comprehension and low asset cost.

Identity: a single continuous route around a visible core; broad purposeful lines and numbered labels; generous negative space. Charcoal #151719, card #222629, warm paper #F5F3E9, acid yellow #E7F56A, lilac #B9A7EE, coral #F39A83. Accent is reserved for action and selection, not monetization urgency. Rounded cards and bold, short headings support phones; patterns and labels accompany color.

Navigation: Play/Home, Customize, Shop, Settings; profile is a compact secondary action. Home's primary action leads to controls and clearly marked mock queue. The arena remains a top-down abstract core/trail view, with no avatar or 3D lobby. Earned currency is server-confirmed; paid interfaces remain unavailable until real products are configured. No paid powers, paid random items, or timed purchase pressure.

Motion: 100–160ms hover/focus and press feedback, cancellable tweens, no continuous menu effects. Reduced motion disables these. Minimum action height 48px, 15px base body type, 100–150% text scale, scrolling at narrow widths, safe area insets, stable focus restoration and modal focus containment.
