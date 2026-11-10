# Preserved implementation checkpoint — design phase starts here

Unapproved Candy Comet presentation changes were preserved on feature/candy-comet-finalization before beginning design research. Known-working bbd39c7 remains untouched. b1767db is the last previously recorded commit.

Source checks passed: 116 Luau sources, formatting, lint, tests, eight builds. These do not certify engine behavior.

Latest two-client test FAILED client-final/winner presentation assertions; server reached Final and verified gameplay events, but both clients reported final=false. Earlier successful tests remain evidence for their earlier revisions only. This pending regression must be diagnosed before shipping these latest presentation edits. Do not label this checkpoint ready.

Normal visible client 10-second sample before final core-detail threshold adjustment: 600 samples, mean 16.668 ms, p95 18.060 ms, maximum 20.274 ms, viewport 1536 x 714.4. This is Studio, not physical-device certification. Earlier normal sample: 18.895 mean /24.513 p95. Managed-client slow render intervals remain unresolved; exact engine/scheduler cause is NOT established.

Audio: original cues prepared; no verified Roblox IDs. asset:read permission check failed. Silent fallback preserved. No uploads, publishing or merging.

Actual captures and recordings are observations of the revisions when captured, not design mockups. after-results.png precedes the pending rematch cleanup; after-home.png shows the new Home. actual-gameplay.png predates the desktop core-detail threshold fix. Recordings may include Studio chrome. The new design-research phase does not continue implementation or certify these changes.
