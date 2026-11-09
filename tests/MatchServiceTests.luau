--!strict
return function()
	local shared = game:GetService("ReplicatedStorage").TrailWars
	local server = game:GetService("ServerScriptService").TrailWars
	local Match = require(server.MatchService)
	local Protocol = require(shared.GameplayProtocol)
	local Profiles = require(server.ProfileStore)
	local Mock = require(server.MockStore)
	local Economy = require(server.EconomyService)
	local n = 0
	local function check(v: boolean, msg: string)
		assert(v, msg)
		n += 1
	end
	for _, bad in
		{
			false,
			1,
			"Join",
			{},
			{ action = "Explode", sequence = 1 },
			{ action = "Join", sequence = 0 },
			{ action = "Join", sequence = 0 / 0 },
			{ action = "Join", sequence = math.huge },
			{ action = "Steer", sequence = 1, matchId = "x", turn = 0.5 },
			{ action = "Join", sequence = 1, position = { 0, 0 } },
			{ action = "Join", sequence = 1, turn = 0 },
		}
	do
		check(not Protocol.validate(bad), "Malformed/forged requests rejected")
	end
	check(Protocol.validate({ action = "Steer", sequence = 1, matchId = "x", turn = -1 }), "Bounded steering valid")
	local profiles = Profiles.new(Mock.new(), function()
		return 1000
	end, "match-tests")
	profiles:load(1)
	profiles:load(2)
	local grants = 0
	local failNext = true
	local attempts = 0
	local m = Match.new({
		namespace = "server-tests",
		config = { CountdownSeconds = 0.1, MaxRoundSeconds = 4 },
		allowRewards = true,
		reward = function(id, mid, won)
			attempts += 1
			if failNext then
				failNext = false
				return false
			end
			grants += 1
			return profiles:transact(tonumber(id:sub(2)), function(p)
				return Economy.roundReward(p, mid, won)
			end)
		end,
	})
	m:add("u1", "ONE")
	m:add("u2", "TWO")
	check(m:request("u1", { action = "Join", sequence = 1 }), "Human1 queues")
	check(m:request("u2", { action = "Join", sequence = 1 }), "Human2 queues")
	for _ = 1, 106 do
		m:step()
	end
	local id = m.round.matchId
	check(m.round.phase == "Active" and m.humanCount == 2, "Two humans begin authoritative match")
	check(not m:request("u1", { action = "Steer", sequence = 2, matchId = "wrong", turn = 1 }), "Wrong match rejected")
	check(m:request("u1", { action = "Steer", sequence = 3, matchId = id, turn = 1 }), "Authoritative turn accepted")
	check(
		not m:request("u1", { action = "Steer", sequence = 3, matchId = id, turn = -1 }),
		"Reordered/stale input rejected"
	)
	m:request("u2", { action = "Steer", sequence = 2, matchId = id, turn = -1 })
	for _ = 1, 22 do
		m:step()
	end
	check(m.round.inputs.u1 == 0 and m.round.inputs.u2 == 0, "Lost releases expire to neutral")
	check(m:request("u1", { action = "Resync", sequence = 4 }), "Resync accepted")
	check(not m:request("u1", { action = "Resync", sequence = 5 }), "Resync abuse bounded")
	for _ = 1, 300 do
		m:step()
	end
	check(m.round.phase == "Results", "Server finalizes timed match")
	check(grants == 2 and attempts == 3, "Transient reward failure retries without duplicate grants")
	local p = profiles:snapshot(1)
	check(p.stats.rounds == 1, "Server match ID reaches existing atomic economy ledger")
	for _ = 1, 100 do
		m:step()
	end
	check(grants == 2 and profiles:snapshot(1).stats.rounds == 1, "Results cannot duplicate rewards")
	m:request("u1", { action = "Rematch", sequence = 6 })
	m:step()
	check(m.round.matchId ~= id and #m.round.sim.index.segments == 0, "Server rematch resets identity and geometry")
	check(m.humanCount == 1 and #m.round.sim.players == 4, "Solo queue becomes labeled practice bots")
	local kept = #m.round.sim.index.segments
	m:remove("u1")
	check(not m.round.sim.byId.u1.alive and #m.round.sim.index.segments == kept, "Disconnect preserves emitted trails")
	local flood = Match.new()
	flood:add("x", "X")
	local rejected = 0
	for seq = 1, 100 do
		if not flood:request("x", { action = "Join", sequence = seq }) then
			rejected += 1
		end
	end
	check(rejected == 60, "Server per-player flood budget enforced")
	local cap = Match.new()
	for i = 1, 8 do
		cap:add(tostring(i), "P" .. i)
		cap:request(tostring(i), { action = "Join", sequence = 1 })
	end
	for _ = 1, 101 do
		cap:step()
	end
	check(#cap.round.sim.players == 6, "Arena has at most six humans")
	local queued = 0
	for _ in cap.queue do
		queued += 1
	end
	check(queued == 2, "Extra joiners wait for next round")

	local waiting = Match.new()
	waiting:add("solo", "SOLO")
	waiting:request("solo", { action = "Join", sequence = 1 })
	for _ = 1, 120 do
		waiting:step()
	end
	check(waiting.round == nil and waiting:snapshot().segmentCount == 0, "Solo grace preserves a valid queue snapshot")
	waiting:add("late", "LATE")
	waiting:request("late", { action = "Join", sequence = 1 })
	waiting:step()
	check(waiting.humanCount == 2, "Slower nearby join pairs before solo fallback")
	print(string.format("MATCH AUTHORITY: %d assertions", n))
	return { passed = n, failed = 0 }
end
