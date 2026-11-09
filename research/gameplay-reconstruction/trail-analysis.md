# Trail specification before kernel implementation

Existing local bot-match screenshots show trail gaps; targeted static inspection reports gap intervals and a hole-distance declaration. Exact runtime scheduling and server hitboxes remain uncertain. The initial Trail Wars mode deliberately uses continuous solid trails, as requested by issue #3. This is a documented custom simplification, not exact reference parity.

Emit segments from authoritative simulated core positions. Every segment stores owner, endpoints, arc-length interval, tick and stable sequence ID. Maintain a spatial hash of segment AABBs. A fixed maximum round duration bounds total segments; never silently erase collision geometry while leaving a round active. End a round explicitly if a configured geometry capacity is reached.

Rendering is separate: native Path2D chunks of at most 48 points with one shared endpoint between chunks, preserving all lethal trail segments. No full-screen screenshot, unbounded single Path2D, one physical Part per sample, or per-frame GUI reconstruction. Reuse core markers and finished chunks; update only the current chunk and new data. Resize rebuilds coordinates in existing objects. Core/trail geometry must preserve arena aspect ratio; screen scaling cannot change collision rules.

Network clients receive sequenced geometry batches and authoritative snapshots. Deltas use reliable events initially; a resync request supplies the current authoritative state when a client detects a gap. No client-supplied trail or collision result is accepted.
