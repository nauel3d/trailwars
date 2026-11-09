# Course markings — selected implementation system

Selected under issue #1 after reviewing existing evidence. The previous requirement to finish every reference branch before visual work is superseded. Research unknowns remain documented; reference inspection is no longer a development dependency.

Source tokens: `src/client/Theme.luau`. Warm paper text, charcoal background, acid-yellow primary actions, lilac trails, coral reserved accent. Flat panels, clear line boundaries and original geometric previews; no uploaded reference assets, mascot, avatar lobby or hoverboard.

| Token | Hex | Role |
|---|---|---|
| Background | #151719 | App canvas |
| Surface | #222629 | Cards / arena |
| Raised | #2C3134 | Hover / selected surface |
| Text | #F5F3E9 | Primary copy |
| Muted | #AEB6B5 | Supporting copy |
| Border | #535B5C | Nonessential panel edges |
| Accent | #E7F56A | Play / keyboard focus / equipped |
| Trail | #B9A7EE | Original trail preview |
| Warm | #F39A83 | Reserved secondary accent |

Typography uses native Gotham fonts, short bold headings and 15–18px body copy. Text settings scale 100–150%; wrapped text is measured at the actual width. Touch actions are at least48px high including secondary header controls. Grid cards collapse3→2→1 columns with width. Home stacks its hero on narrow screens. Main content scrolls; safe area is respected.

Motion is restricted to cancellable120ms button feedback. Reduced motion removes tweens. Connections/tweens are scoped per app mount and disposed on navigation/unmount. No per-frame tree construction or decorative blur/glow/video. Component previews use isolated mock data; the live app uses server-confirmed profile responses.

Home offers one yellow Play action, an original route/core graphic, and concise secondary customization/progress actions. Four destinations stay consistent: Home, Customize, Shop, Settings. Profile is secondary. Mock queue/HUD/results remain clearly labeled; paid items are unavailable until actual commerce integration is configured.

CLI build/test results and bundled Studio visual verification are separate evidence. A successful Rojo build is not a visual pass.
