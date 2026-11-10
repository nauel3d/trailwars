# Launch-readiness audit — 2026-11-10

Status: **not release-ready**. This is a source audit and an engineering work ledger, not certification. Start point: `c452623` (PR #10 artwork/browser prototype, including preserved Candy Comet code at `7419afd`). Work branch: `feature/launch-reliability`. Known-working fallback: `bbd39c7`, unchanged.

## Entry points and existing functionality

| Area | Actual implementation | Gap / release risk |
| --- | --- | --- |
| ProfileStore | Atomic UpdateAsync, per-user serialization, expiring owner lease, cache unavailable during writes, stale-owner rejection, release and heartbeat | No bounded service-level retry on transactions/releases; no real staging failure/recovery certification. Shutdown behavior needs concurrent-write tests. |
| ProfileSchema | Rejects unknown versions and malformed known fields, copies data, never defaults failed loads | Only v1 accepted; additive playtest extension is validated separately. Public snapshot currently exposes playtest deduplication ledgers. No pass ownership field. |
| EconomyService | Earned-coin purchase, equip, validated preferences, atomic receipt tombstone + cosmetic grant, reward deduplication | Reward callback is not connected to playable series. Fixed ledger caps eventually block grants; do not prune purchase tombstones unsafely. No repeatable product grants. |
| PurchaseService | One ProcessReceipt owner, disabled in mock/live-off, retries unknown/unavailable receipts | No pass verification/recovery, repeatable products, product metadata validation, purchase UI integration or purchase telemetry. No real IDs configured. |
| Main.server | Profile/economy remote, Studio mock or explicitly gated DataStore, loading retry, heartbeat, bounded shutdown wait | Default project mounts legacy client; it does not mount the complete playable client/server entry point. Do not run alongside another independent profile owner. |
| MatchService | Older authoritative single-round coordinator, protocol validation, pending rewards | Not the playable cumulative/powers coordinator. Preserve for existing tests; do not replace working mechanics with it. |
| PlaytestMatchService | Cumulative series, Homing/Jump, eliminated rockets, authoritative kill attribution, standings, final/rematch callbacks, intent sequence/rate validation | Adapter hard-codes mock storage. Defaults are target 40 / five-round cap / overtime, while test fixtures force completion in three rounds: document this distinction, do not claim every match is fixed-three-round. |
| PlaytestStats | Additive legacy-safe stats, round/match idempotence, monotonic session elapsed-time deltas | Ledgers capped at 2,000 round/match entries; sessions unbounded. Lifetime data is only in-memory in playable place. Failures retained in adapter pending list without bounded backpressure. |
| PowerService | Server cooldown clocks, server projectile simulation/contacts, Jump collision state, bounded projectile count | Preserve authoritative rules. Verify remotes, duplicate intents and adversarial payloads. |
| PlaytestServer | One mock profile owner, real multiplayer remotes, streaming geometry, bots, real stats and leaderstats | Profile load is synchronous in join callback; players still enter match on load failure. DataStore opt-in, shutdown coordination, staging and premium profile/economy UI integration missing. |
| Networking | Server derives identity from Player; no remote accepts kills, collision outcomes, coin deltas or rewards | Enumerate each remote and budget, add malformed/deep/extra-field/NaN/replay/flood coverage and bounded audit. Studio-only test reports/probes must stay out of release build. |
| Premium UI | PR #10 original alpha artwork and layered browser prototype, existing native motion/lifecycle primitives | Native integration not yet complete. Browser balances/purchases are mock and must never become production truth. Asset IDs absent; asset read/write scopes rejected. |
| Analytics | None found in src or playable adapter | Server-authoritative economy/funnel/custom adapter and consent-safe bounded diagnostics missing. Studio cannot prove delivery to a live dashboard. |

## First reproduced blocker

The unchanged connected engine-test place reproduces the saved failure: both clients reach Active, intermission and rematch; server reaches Final and authoritative stats settle. Player 1 misses Final; Player 2 observes Final but not the winner card. Both winnerPresentation flags are false. Full tool result is retained as `qa/launch/baseline-two-client.json`.

The test server sets Nov10Rematch as soon as it sees server Final. A client can receive that attribute before the corresponding 10 Hz gameplay packet and invoke Start(), hiding results. The first diagnostic change holds rematch until **both clients report Final and a visible nonempty winner card**. This preserves the assertions and makes a genuinely missing winner screen fail rather than clearing it early. No server gameplay, collision, powers or scoring change has been made.

## Safety and pending gates

- Config.EnableProductionProfiles=false; Config.EnableLivePurchases=false.
- No IDs or prices invented; no purchases, production writes, merges or public release.
- User now authorizes creating/saving the main playable experience privately under **Ziggle** (not Ziggo/Zigo). Verify the exact owner in the creation dialog before saving; record resulting universe/place IDs. Current local files have GameId=0 and PlaceId=0.
- Current Open Cloud asset:read, asset:write and universe:write probes are ungranted. No upload or cloud save occurred. User will configure MCP after private creation.
- Studio's main playable file is open, but desktop automation reports `window crop is outside captured monitor`; user has been given private-save instructions. Do not claim the experience was saved before verifying its IDs.
- Managed-client ~90 ms render intervals remain unresolved. Do not infer scheduler cause or physical-device FPS. Keep prior evidence and do not let that investigation displace the release blockers.

## Verification order

1. Resolve Final/winner observation and sustained visible result, then actual rematch with two clients. Preserve failed baseline.
2. Harden shared profile schema/store with fault-injected tests, then one profile owner for playable/economy adapters. Staging only after tests and permissions.
3. Disabled-by-default Marketplace adapters: explicit configuration, atomic durable grants, passes and repeatable product tests. Real charge testing is a separate gate.
4. Remote audit/adversarial tests; analytics contracts and event mapping; success events only after successful authoritative operations.
5. Separate native premium UI branch, reusable optimized assets, responsive real-state screens, cancellation/reduced motion; actual Studio captures and comparisons.
6. Full engine release matrix, measured performance, rollback and draft PRs. No release-ready claim while critical gates remain.

## Progress update

- The user created the private **Trail Wars** experience. Engine and Open Cloud agree: universe `10775671980`, root place `140477196119431`, creator group `206215093`. GroupService confirms the owner name **Ziggle**; Open Cloud confirms visibility **PRIVATE**. Earlier local-file/permission observations above are historical, not current target IDs.
- Both asset scopes now pass after user configuration. Fourteen original audio files uploaded under Ziggle, all approved and active. The actual saved-place client preloaded all 14 successfully; lengths 0.065–0.51 s. Separate audio evidence is in qa/launch. Assets being published is distinct from making the experience public; experience access remains private.
- ProfileStore retries only idempotent load/release lease operations, at most three attempts with short backoff. Generic mutations are never blindly retried after an ambiguous error. Such errors invalidate the cache, requiring durable reconciliation; playable stats retry the same event/session ID after reconciliation.
- New deterministic fault tests exercise throttled load, post-commit response loss, duplicate reward replay, release response loss, reconnect, sustained failure and shutdown. The existing failure/recovery tests now explicitly reconcile before replaying an event; their original no-duplicate/no-data-loss assertions remain.
- Full command-line check passed: formatting, zero lint warnings/errors, 117 Luau sources compiled, **767 assertions** across foundation/gameplay/series/presentation/reliability suites, 33 responsive cases, motion models and eight Rojo builds. These are not live DataStore or device certifications.
- Revised Final test requires a real nonempty winner card continuously visible for 300 ms on both clients before rematch. The diagnostic-only run before evidence retention correction still failed: historical success was overwritten after Start hid the old card. No gameplay mechanics were changed to satisfy the test.
- Subsequent automated-client attempts returned nil during interruption and then failed with `Two clients did not start`, ready=0. The associated fresh worker logs show backend configuration and OAuth discovery connection timeouts. This is an engine-test startup failure, not a gameplay pass and not evidence that the winner regression is resolved. Preserve the original failed baseline. Retry after worker connectivity recovers or use a different actual-client test route.
- Native premium UI integration, production persistence, Marketplace products/passes, analytics, security expansion and the complete release matrix remain outstanding. Nothing is declared release-ready.
