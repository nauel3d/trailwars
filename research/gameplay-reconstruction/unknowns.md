# Evidence limits and prototype choices

Measured-image estimates from the official trailer and recovered installed-client declarations are complementary, not interchangeable. The trailer's build, playback timing, powers and exact world scale are unknown. No authoritative commercial server implementation was recovered.

Unresolved: current practice-room locality, arena dimensions, actual input latency, exact ramp interpolation, newest-self-trail exclusion, server collision geometry, simultaneous-hit policy, spawn safety, full countdown/restart timing, and online network reconciliation. A previous local bot match was observed, but that does not prove an offline authoritative practice engine.

Implementation choices are therefore explicit custom decisions: original swept-capsule math; chronological same-tick collision handling; short arc-length self-tail exclusion; no random trail gaps in the initial continuous-trail mode; three-second countdown; bounded round duration; analytical 2D broad phase; no powers; one human plus bots first. Roblox world dimensions/visible sizes are tunable and must be compared in normalized arena units.

Initial scale selection: 1300×800 world units, speed105, angular rate2.6rad/s, visible core radius6.5, collision radius4.5, trail half-width4. This gives speed0.0808 arena-width/s, nominal turn radius0.0311 arena-width, visible trail width0.00615 arena-width and core diameter0.0100 arena-width. These custom scale/visual choices fall within the trailer's approximate visual intervals; they do not prove current-build parity. Collider sizes remain custom, visibly distinct from recovered client radii2.8/2.0 pending playtest.

Milestones A–C may proceed with these unknowns labeled; do not continue investigating cosmetic/monetization surfaces. Any blocked practice session is recorded rather than weakening security restrictions or instrumenting online matches.
