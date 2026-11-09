# Execution and approval plan

Current branch experiment was preserved at commit 37280fe. Main stays d7b7480. The current client is a WIP artifact, not the approved implementation. This plan is the next review gate.

## Before approval: this package

1. Audit routes, states, contracts and existing art. Separate present, mock, proposed, later and excluded features.
2. Define navigation/focus and complete recovery paths. Keep one Quick Play action, no mode selector or new economy.
3. Define adaptive layout and component/state contracts, preserving the approved identity.
4. Author all major screens, representative modes, state variants, component and motion boards. Keep editable source and explicit sample-data labels.
5. Review text/geometry, consistency, action priority, mobile reach, implementation feasibility and remaining unknowns. Present the whole package and stop for explicit owner approval.

No further production Luau edits, Studio iteration, game publication, merge, paid activation or gameplay implementation occur during this design checkpoint.

## After explicit approval only

| Slice | Work | Acceptance before next slice |
|---|---|---|
| 1 Design-system proof | One canonical Button/ItemTile/Dialog/ScreenShell; asset-rim alternatives | Three layout modes, real text/hit bounds, scoped cleanup, reference comparison; abandon failing approach after two meaningful attempts |
| 2 Home and root navigation | Approved single-screen Home, safe areas, modality/focus | Play and all root destinations visible without page scroll at representative sizes |
| 3 Collection/shop/details | Shared catalog, owned/equipped/locked states, fixed actions, bounded grid | Current four items; existing Equip/BuyEarned behavior retained, no fake offers |
| 4 Transaction/recovery | Confirm, cancel, pending, unknown and reconciliation views | No duplicate write; no false failure/refund claim; parent/focus restoration |
| 5 Profile/settings | Confirmed stats and existing fields, preference handling | No invented levels; partial/default saves honestly reported |
| 6 Play-flow presentation | Controls, queue, countdown, HUD, spectator, results fixtures | Explicit mocks only; no implementation of gameplay or queue backend |
| 7 Entry and shared feedback | Loading/error/connection, dialogs, notifications | Recovery always reachable; message survives until actionable error resolves |
| 8 Bundled verification | CLI, UI Labs smoke, geometry/input/lifecycle/device profiling, side-by-side captures | Verified claims documented by build/device; PR ready for visual review |

## Integration work not authorized by this UI approval

Real matchmaking/join/cancel/rejoin, match simulation, authoritative timer/placement/reward feeds, persistent tutorial acknowledgment, new catalog items, production profile enablement, paid products and asset publication of the game require separate implementation/approval. UI fixtures can depict their presentation without pretending those services exist.

## Commit strategy

Continue the feature branch, no force push. Commit design and approved component slices coherently, keep tests and all raw research. Do not merge before owner review. A design-review draft PR may contain this package, clearly distinguishing unapproved preserved experiments from planned final work.

## Approval request

Review the complete screen set, Home no-scroll behavior, mode transformations, navigation/state semantics, visual system and launch cuts. Approval applies to the reviewed design version, not to future aesthetic changes or new systems. Silence is not approval. Requested revisions remain in design files before implementation resumes.
