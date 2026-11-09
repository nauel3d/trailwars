# Performance and lifecycle strategy

No mobile benchmark has been run for the proposed system. Prior Studio frame observations apply only to their recorded builds and host sessions; they are not targets already achieved by these mockups.

## Initial engineering budgets to validate

- Home should mount only its shell, preview art and five meaningful actions; no hidden inventory/settings trees. One controller/state owner per app, one view scope per route.
- Reuse texture IDs for identical hashes. The preserved card_plum and button_plum are duplicates and should share one runtime texture. Remove unused prototype assets from the shipped asset map after approval, preserving sources in design history.
- Prefer small nine-slice shells and an icon atlas where padding/mip sampling are proven. Do not atlas complex stretchable borders merely to reduce file count. No 4K full-screen UI sprites.
- Keep backdrop opaque; limit layered translucent area. No nested full-screen CanvasGroups or blur stacks. Texture memory estimate = unique decoded width×height×4, plus mip/engine overhead; compressed PNG bytes are not GPU memory.
- Animate one local property owner at a time; no constant rebuilds, per-frame layout, hover particle loops or polling remotes. Coalesce resize events. Only real state changes request a snapshot; rate-limit and reconcile unknown writes.
- Four-item catalog needs no virtualization. Consider it only if measured inventory size and mount costs justify it later.
- Critical preloads: logo + primary shell + selected mode's necessary art; render a readable native fallback on failure. Secondary catalog/celebration art loads lazily. Do not hold Play behind decorative art indefinitely.

## Measurements after approval

Record hardware/device, viewport, input, build SHA and cold/warm load. Observe UI construction CPU time separately from network and render completion. Sample frame times and spike traces during open/close/equip/resize. Compare unique image allocation and total client memory separately. Repeat 100 route/dialog cycles and compare live Instance counts, owned connections/tweens and pending callbacks. Check input-to-feedback delay with actual pointer, controller and touch.

Provisional goals: no sustained frame-loop work from idle menus, no monotonically growing resources after cleanup, no obvious UI spikes on target low-end phones, and immediate local press feedback even while a server operation is pending. Set numeric release limits only after real device baselines exist. Reject a cosmetic improvement if it creates visibly sluggish controls.
