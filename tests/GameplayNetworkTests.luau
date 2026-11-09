--!strict
return function()
	local Replica = require(game:GetService("ReplicatedStorage").TrailWars.GameplayReplica)
	local n = 0
	local function check(v: boolean, msg: string)
		assert(v, msg)
		n += 1
	end
	local r = Replica.new()
	local function packet(rev, from, full, ids, matchId)
		local segments = {}
		for _, id in ids do
			table.insert(segments, { owner = "a", ax = id, ay = 0, bx = id + 1, by = 0 })
		end
		return {
			state = { matchId = matchId or "round1", revision = rev },
			from = from,
			full = full,
			segments = segments,
		}
	end
	check(r:accept(packet(1, 1, true, { 1, 2 })), "Initial authoritative full frame")
	check(#r:drain() == 2 and #r:drain() == 0, "Geometry delta drained exactly once")
	check(not r:accept(packet(3, 4, false, { 4 })), "Missing packet detected before appending future geometry")
	check(r.received == 2 and r.state.revision == 1, "Gap does not corrupt prior authority")
	check(r:accept(packet(4, 1, true, { 1, 2, 3, 4 })), "Full resync restores missed geometry")
	check(r.received == 4 and #r:drain() == 4, "Resync rebuild has no duplicate prefix")
	check(not r:accept(packet(2, 1, true, { 1 })), "Delayed stale full frame cannot roll authority backward")
	check(r.received == 4, "Stale reset preserves geometry")
	check(r:accept(packet(5, 5, false, { 5, 6 })), "Reliable stream continues after resync")
	check(not r:accept(packet(5, 5, false, { 5, 6 })), "Duplicate geometry is rejected by sequence offset")
	check(not r:accept(packet(1, 1, false, { 1 }, "round2")), "New match requires full reset")
	check(r:accept(packet(1, 1, true, { 1 }, "round2")), "Rematch accepts lower revision with new identity")
	check(r.received == 1 and #r:drain() == 1, "Previous match geometry discarded")
	r:clear()
	check(r.state == nil and r.received == 0, "Leaving releases replicated geometry")
	print(string.format("NETWORK STREAM: %d assertions; simulated gaps/reorder/resync, not live network throttling", n))
	return { passed = n, failed = 0 }
end
