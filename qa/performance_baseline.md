# Preserved prototype observation

Before the issue #1 workflow change, desktop Studio sampled 120 RenderStepped frames at 1365×768: median 16.594ms, p95 17.827ms, max 18.294ms, mean 16.656ms. Initial GUI construction CPU time was 6.066ms. Reported total client memory was 2632.37MB and included Studio/assets; it is not an isolated UI allocation.

These are historical observations, not a phone benchmark. Steam, automation, Studio session and viewport differed from the final checkpoint, so no performance regression or improvement can be inferred. See [the final checkpoint](studio_verification.md) for current scoped measurements.
