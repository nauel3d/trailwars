# Original collision design before kernel implementation

Reference elimination causes and server collision algorithm remain unknown. Static client hit-testing is not evidence of authoritative collision behavior; tryKill() being a stub is an explicit boundary. This implementation uses original continuous geometry.

Core centers are moving disks. Trails are line segments with circular end caps. Broad-phase uniform-grid AABB queries return candidate segment IDs; narrow-phase swept point vs capsule computes earliest time of impact using endpoint quadratics and the segment's side boundaries. Boundaries are inset by core radius. Tangent contact counts as collision within a tiny configured tolerance. Degenerate segments reduce to circles.

Head-on and crossing contact use relative swept disk motion. Newly drawn opponent trails require a growing-segment sweep, so a player cannot collide with a future portion of an opponent's path. Resolve the earliest collision event across all alive players, advance everyone to that event, commit only the actual prefix of their trails, eliminate every participant at the same time (within numerical tolerance), then simulate the remaining fraction. This avoids player-iteration advantage and prevents a previously eliminated core from drawing a lethal future segment.

Self-collision ignores only an arc-length suffix immediately behind the player's own core. The custom suffix is based on core radius + trail radius + one maximum step, not a broad elapsed-time immunity. Old self trails remain lethal. No physics Parts or Touched callbacks determine the outcome.

Prototype tests must cover straight/crossing/tangent/degenerate capsules, high-speed sweeps, same-tick trail growth, self loops, simultaneous impacts, dead-path truncation, wall hits, and storage-order independence. Numerical tolerance and collision geometry are original Trail Wars decisions, not recovered server logic.
