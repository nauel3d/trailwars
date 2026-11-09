# QA execution plan

All status claims require saved evidence. Rojo build validates serialization only. Studio mock tests do not prove live DataStore or Marketplace behavior.

| Area | Acceptance | Required environment |
|---|---|---|
| Profile schema | Corrupt/future data rejected; private receipt and lease fields omitted from public reply | Studio module tests |
| Sessions | Second live lease rejected; expired lease recovered; stale writer rejected | Two injected stores, then two published private test servers |
| Earned purchase | Insufficient balance unchanged; owned purchase cannot charge twice; server catalog owns cost | Module + live mock UI |
| Equip | Unknown/unowned rejected; equipped state visible after confirmed server response | Module + client/server |
| Settings | Invalid/NaN/out-of-range rejected; confirmed values displayed; failure retains prior display | Module + UI |
| Receipts | Same receipt retries grant once, conflict rejected, write failure returns NotProcessedYet | Injected store; later approved test product |
| Mock flow | Queue/countdown/HUD/spectator/results/rematch traversable; no stats/reward mutations | Studio local play |
| Navigation | All visible actions work; back/focus/modal disposal; 100 cycles without instance/connection growth | Desktop + keyboard/gamepad |
| Responsive | 320/390 phone, tablet, desktop; 100/150% text; scroll reaches every action; safe insets | Studio emulation then physical devices |
| Controls | A/D/arrows/D-pad/touch zones visibly respond and release on focus loss | Studio emulation; physical controller/touch pending |
| Failure recovery | Delayed write outcome remains unknown until snapshot; duplicate buttons locked; reconnect safe | Injected faults + network emulator |
| Payments | Paid placeholders cannot prompt; eventual price comes from runtime product info; grant only receipt | Current disabled config, later approved real catalog |
| Performance | Record GUI CPU build scope, dt samples, Stats memory; distinguish Studio and target device | Studio then target phones |

Production release remains gated on published private test universe, full two-server race/failure tests, physical devices, safe receipt archival/retention, actual product mapping and approval to publish/charge. No production readiness claim.
