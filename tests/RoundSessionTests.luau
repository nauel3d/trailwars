--!strict
return function()
	local shared = game:GetService("ReplicatedStorage").TrailWars
	local Round = require(shared.RoundSession)
	local Layout = require(shared.GameplayLayout)
	local n = 0
	local function check(v: boolean, message: string)
		assert(v, message)
		n += 1
	end
	local r = Round.new(
		{ { id = "you", x = 100, y = 100, heading = 0 }, { id = "bot", x = 300, y = 300, heading = 0, isBot = true } },
		{ CountdownSeconds = 0.1, MaxRoundSeconds = 0.2, Speed = 10, RampSeconds = 0 },
		"first"
	)
	local x = r.sim.players[1].x
	for _ = 1, 4 do
		Round.step(r)
	end
	check(r.phase == "Countdown" and r.sim.players[1].x == x, "Countdown does not move cores")
	for _ = 1, 20 do
		Round.step(r)
	end
	check(r.phase == "Results" and r.sim.reason == "TimeLimit", "Timed round ends")
	local tick = r.sim.tick
	Round.step(r)
	check(r.sim.tick == tick, "Results freeze lethal simulation")
	local nextRound = Round.new(r.roster, nil, "second")
	check(nextRound.matchId ~= r.matchId and #nextRound.sim.index.segments == 0, "Rematch resets geometry and identity")
	Round.step(nextRound)
	Round.remove(nextRound, "you")
	check(not nextRound.sim.byId.you.alive, "Disconnect removes live core")
	for _, size in
		{ { 320, 568 }, { 390, 844 }, { 844, 390 }, { 568, 320 }, { 768, 1024 }, { 1366, 768 }, { 1920, 1080 } }
	do
		local w, h = size[1], size[2]
		local l = Layout.compute(w, h)
		local f = l.field
		check(
			f[1] >= 0 and f[2] >= l.top and f[1] + f[3] <= w and f[2] + f[4] <= h - l.bottom,
			"Arena respects safe controls"
		)
		check(math.abs(f[3] / f[4] - 1300 / 800) < 1e-8, "Arena retains world aspect without stretch")
	end
	print(string.format("ROUND/LAYOUT: %d assertions", n))
	return { passed = n, failed = 0 }
end
