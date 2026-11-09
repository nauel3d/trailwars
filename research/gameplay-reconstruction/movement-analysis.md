# Movement specification before kernel implementation

Owner target: Curve Fever Pro Steam app 1133700, installed build 26292297, UI 4.3.0. This is original algorithm design informed by reference evidence; no proprietary code is included. Companion REA/video reports record source identities, offsets and limitations.

The first targeted static investigation reports client declarations of 50 ticks/s, normal speed 2.1 units/tick, rotation 3°/tick with fixed-point quantization, radius 4 and a 500ms initial ramp. These establish shipped client declarations, not authoritative server operation. Nominal conversion is 105 units/s and about 149–150°/s, giving a full-speed turn radius near 40 units. Exact arena normalization and startup response remain subject to corroboration. See rea-investigation.md rather than treating a found constant as a runtime measurement.

Trail Wars initial tunable targets: reference-like world units, constant full speed 105 units/s, angular velocity 149°/s, fixed 50Hz simulation, linear 500ms startup ramp as an explicitly custom approximation of the recovered ramp declaration. Integrate a turning interval analytically as a circular arc; sweep its short chord for collision. Both steering buttons held means neutral. Release immediately returns angular velocity to zero; no inertial drift. Left/right input is −1/+1, not an externally supplied angle or position.

Arena bounds, countdown, visible core size, collision tolerance, self-trail grace, maximum round duration and bot strategy are Trail Wars custom tunables until validated against footage. Do not claim parity. Preserve reference and custom parameter categories in GameplayConfig and QA.

Use a fixed-step accumulator with a bounded number of catch-up steps per rendered frame. Simulation time must never jump over unsimulated collisions. Long stalls enter slow catch-up and expose discarded wall-clock backlog diagnostics; rendering framerate does not alter a simulated step. Deterministic replay requires the same seed, initial state and tick-indexed input stream.
