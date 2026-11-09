# QA matrix and evidence policy

This file is a test plan, not a pass report. The preserved implementation's last CLI suite passed; its latest 96-case text diagnostic did not. The static mockup package validates design files only. New engine/device/input checks resume after design approval.

## Representative matrix

| Axis | Cases |
|---|---|
| Viewport before platform insets | 320×568; 360×640; 390×844; 568×320; 844×390; 768×1024; 1024×768; 1280×720; 1672×941; 1920×1080; 2560×1080 |
| Text preference | 100%, 125%, 150% |
| Input | pointer/keyboard, actual touch, controller, modality switch during focus/press |
| Data | confirmed fixture, missing profile, stale profile, zero history, long name, 999,999,999 coins, long localized copy |
| Item | starter owned, locked affordable, insufficient, equipped, pending, unavailable, missing art |
| Transaction | cancel before submit, success, business reject, delayed write, timeout unknown, busy snapshot, late reply, reconcile success/failure |

Eleven viewport sizes × three text sizes = 33 geometry contexts per major state, not proof of every possible device. Run generated state matrices selectively by changed component and broaden at meaningful integration checkpoints.

## Assertions after approval

| Area | Concrete acceptance |
|---|---|
| Home | no page Scrollbar/ScrollingEnabled; Play and all four destinations inside safe rectangle; no scroll needed |
| Containment | visible critical bounds inside safe area; parent visibility accounted for; no offscreen Close/Cancel |
| Touch | effective screen-space action height/width ~48px minimum practical, gap ≥8px; visible and hit rectangles agree |
| Type | actual TextFits plus measured bounds, label contrast, enlarged/long copy; no decorative hidden/shadow false positives |
| Layout | no critical rectangle overlaps, no constraint oscillation, stable after ten orientation/resize round trips |
| Navigation | semantic focus order, A/Enter/Space activation once, B/Escape/Back equivalent, no hidden targets/dead ends |
| Modal | parent inactive, focus trapped, safe default Cancel/Stay, parent selection/scroll restored by stable item ID |
| Inventory | local selection does not grant/equip; confirmed ownership/equipped only; starter reset uses Equip |
| Purchase | cancellation before submit leaves balance unchanged; pending/unknown cannot submit twice; snapshot cannot clear unresolved durable write |
| Settings | actual values, save pending/error, reduced motion, muted cues, partial restore defaults truthfully displayed |
| Entry / errors | profile unavailable never means zero owned/balance; Retry and meaningful recovery always reachable |
| Match mock | labeled mock; no local wins/XP/reward mutations; HUD controls do not obscure critical field |
| Lifecycle | 100 root/modal cycles without increasing live view resources; canceled tweens and cleared input on focus loss |
| Assets | real IDs, current hashes, alpha edges, no baked text, valid slice rectangles, duplicate hash reuse |
| Performance | scoped construction, frame samples and memory on named devices/builds, no fabricated benchmarks |

## Evidence tiers

1. Static design export: authored SVG/PNG geometry and readability review. No engine semantics implied.
2. CLI: formatting/lint/compile, 40 foundation assertions, Rojo builds/boundary. No visual/device claim implied.
3. Studio isolated component/story + real API geometry: text, focus, layout and clean remount.
4. Studio simulated device: safe-area/layout and native input emulation, clearly labeled.
5. Physical phone/tablet/controller: usability, reach, input release, pixel density, performance.
6. Private live-universe integration: multi-server data races, actual commerce only after separate authorization.

Report exact build and scope, failures and limitations. A Frame-sized simulation is not hardware evidence. A successful screenshot is not functional purchase evidence. A historical pass does not automatically apply after a source change.
