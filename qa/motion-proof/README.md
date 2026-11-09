# Living SNAP ARCADE review checkpoint

Continue from 785b54f. Review `index.html`, the 12-second `home-demo.mp4`, and the actual Studio screenshots. The video is a crop of a local Studio window recording, not a rendered mockup. It is silent: audio upload is still blocked. Raw window recording and extracted check frame are retained beside it.

## Implemented in the isolated proof

- Shared motion tokens/scope: cancellable property ownership, guarded completion, visible-time timers, bounded loops, window/ancestor visibility pausing, reduced motion and disposal.
- Home: three independently simulated decorative cores, turns, obstacle/trail avoidance, capped growing trails, occasional crashes, restart, and a labeled demo standings panel. No gameplay server, remotes or real statistics are used.
- Standings: stable IDs, deterministic ties, coalesced reorder tweens, temporary upward-placement feedback, elimination state and explicit final ranks. HUD option suppresses flourish. No authoritative-match adapter is invented.
- Customize: moving cosmetic preview, selection, owned/unowned distinction and local demo equip.
- Shop: inspect, demo confirmation, guarded pending state, cancellation/failure feedback and simulated success. No purchase, profile mutation or balance grant.
- Results: victory/defeat replay, final placement, two explicitly labeled preview reward rows, short reveals, bounded accents and a gentle core float. No rewards are granted.
- Preview settings: immediate reduced-motion and mute controls. These are local preview preferences, not a replacement for existing saved settings.

All 46 prior proposals and navigation/layout planning remain intact. `design/motion-system` maps the complete system to shared motion policies. The remaining screen implementations are held for approval of these demonstrations.

## Validation

CLI: StyLua, Selene (zero errors/warnings), 56 Luau sources compile, 40 foundation assertions, 33 Home viewport/text-size geometry cases, production/preview Rojo builds and artifact boundary checks pass. The isolated `snap-proof.project.json` also builds.

Pure decorative model: 120 simulated seconds, 16 crashes, 1115 turning steps, maximum 47 retained trail points. Determinism, bounded coordinates/history, stable tie sorting, elimination order, final placement and bad-input rejection were checked. Rendering appends the current endpoint without exceeding 48 Path2D points.

`engine-checks.json`: 33 Home engine frame-size cases with 165 destination callbacks; 16 demo-screen cases; no remaining reported text-fit failures; canceled tween completion, hidden-screen pause, reduced-motion stop, cleanup, stable row identity, latest-order coalescing, elimination and final placement all pass. The arena diagnostic retained 56 objects before/after its sample. That count refers to the test subtree, not the whole app. It is not a CPU/GPU or physical-device performance benchmark.

Runtime: native source bootstrap in Studio, real pointer navigation/selection/equip, demo confirmation→pending→success, Back and Play/Results navigation checked. Home reviewed on desktop and iPhone 13 emulation in portrait (389×704 safe region) and landscape (749×331 safe region). Fixed disclaimer/status overlap and refined the desktop panel width. Editor tests use a visible temporary GUI; hidden/offscreen test hosts and insufficient text-layout settling can produce false text-fit failures, so the final diagnostics use explicit visible hosts and a settling wait. Physical touch/controller hardware, exhaustive localization and frame profiling remain future checks.

Studio was stopped and reset to its default viewport; the edit-time living Home preview was restored. Existing built-in Assistant plugin-loading and unrelated asset-type warnings remain in the Studio log. No clean-console claim is made.

## Audio limitation

Three original, synthesized short cues are stored in `assets/snap-audio`, with a reproducible script and no sampled Nintendo material. Playback has mute/volume, repeat suppression and a three-voice cap. Roblox continued to report `asset:read` ungranted after creator confirmation and retries; the attempted file upload also rejected the upload directory. No sound assets were created and no IDs were fabricated. The ID map remains empty, so the preview runs silently. The review gallery can play the original local WAVs independently of Roblox.

## Review gate

Approve the motion and interaction direction for Home, Customize, Shop and Results before rollout to the remaining planned screens. No production UI router, backend, gameplay, purchases, publishing or merge was changed. Build/open `dist/TrailWarsSnapProof.rbxlx` from `snap-proof.project.json` for the interactive local proof; `default.project.json` retains the previous application.
