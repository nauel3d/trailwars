--!strict
return function()
	local Series = require(game:GetService("ReplicatedStorage").TrailWars.MatchSeries)
	local passed = 0
	local function check(v: boolean, message: string)
		assert(v, message)
		passed += 1
	end
	local function roster(n: number)
		local out = {}
		for i = 1, n do
			table.insert(out, { id = "p" .. i, name = "PLAYER " .. i })
		end
		return out
	end
	local function outcome(n: number, winner: number?)
		local out = {}
		local order = {}
		if winner then
			table.insert(order, winner)
		end
		for i = 1, n do
			if i ~= winner then
				table.insert(order, i)
			end
		end
		for rank, i in order do
			table.insert(
				out,
				{ id = "p" .. i, alive = winner ~= nil and rank == 1, placement = if winner then rank else n }
			)
		end
		return out
	end
	for n = 2, 6 do
		local s = Series.new("circuit" .. n, roster(n))
		check(s.phase == "Ready", "Series starts without a running round")
		for round = 1, 3 do
			local ok, id = s:beginRound()
			check(ok, "Begin each planned round")
			check(not s:beginRound(), "Cannot create overlapping round")
			check(s:settleRound(s.matchId, id, round, outcome(n, 1)), "Authoritative outcome accepted")
			local revision = s.revision
			check(s:settleRound(s.matchId, id, round, outcome(n, 1)), "Duplicate settlement is idempotent")
			check(s.revision == revision and #s.history == round, "Duplicate adds no points/event/history")
			check(s.byId.p1.score == n * round, "Winner receives outlived points plus one bonus")
			check(s.byId["p" .. n].score == 0, "First eliminated earns zero")
			if round < 3 then
				check(s.phase == "Intermission", "Round win does not finish match early")
			end
		end
		check(
			s.phase == "Final" and #s.winnerIds == 1 and s.winnerIds[1] == "p1",
			"Circuit highest cumulative score wins"
		)
		check(not s:beginRound(), "Final cannot silently rematch")
		local nextMatch = Series.new("rematch" .. n, roster(n))
		check(
			nextMatch.byId.p1.score == 0 and #nextMatch.history == 0 and nextMatch.matchId ~= s.matchId,
			"Rematch requires fresh identity and totals"
		)
	end
	local ties = Series.new("ties", roster(2), { Rounds = 1, MaxOvertimes = 1 })
	local _, tieId = ties:beginRound()
	ties:settleRound("ties", tieId, 1, outcome(2, nil))
	check(ties.phase == "Intermission" and ties.nextOvertime, "All-dead tie schedules bounded overtime")
	local _, otId = ties:beginRound()
	ties:settleRound("ties", otId, 2, outcome(2, nil))
	check(
		ties.phase == "Final" and ties.reason == "SharedVictory" and #ties.winnerIds == 2,
		"Unresolved overtime ends in shared victory"
	)
	local positions = ties:snapshot().players
	check(positions[1].rank == 1 and positions[2].rank == 1, "Stable ordering does not break equal-score ties")
	local sprint = Series.new("sprint", roster(3), { Mode = "Sprint", Target = 5, MaxRounds = 5 })
	local _, r1 = sprint:beginRound()
	sprint:settleRound("sprint", r1, 1, outcome(3, 1))
	check(sprint.phase == "Intermission" and sprint.byId.p1.score == 3, "Sprint carries totals below target")
	local _, r2 = sprint:beginRound()
	sprint:settleRound("sprint", r2, 2, outcome(3, 1))
	check(sprint.phase == "Final" and sprint.byId.p1.score == 6, "Sprint checks threshold after round settlement")
	local cap = Series.new("cap", roster(3), { Mode = "Sprint", Target = 999, MaxRounds = 1 })
	local _, capId = cap:beginRound()
	cap:settleRound("cap", capId, 1, outcome(3, 2))
	check(cap.phase == "Final" and cap.winnerIds[1] == "p2", "Sprint round cap prevents indefinite series")
	local timed = Series.new("time", roster(4), { Rounds = 1, MaxOvertimes = 0 })
	local _, timeId = timed:beginRound()
	check(
		timed:settleRound("time", timeId, 1, {
			{ id = "p1", alive = true },
			{ id = "p2", alive = true },
			{ id = "p3", alive = false, placement = 3 },
			{ id = "p4", alive = false, placement = 4 },
		}),
		"Time-limit survivors can tie without a sole-winner bonus"
	)
	check(
		timed.byId.p1.score == 2 and timed.byId.p2.score == 2 and #timed.winnerIds == 2,
		"Only strictly earlier deaths count"
	)
	local safe = Series.new("safe", roster(3))
	local _, safeId = safe:beginRound()
	check(not safe:settleRound("other", safeId, 1, outcome(3, 1)), "Cross-match settlement rejected")
	check(not safe:settleRound("safe", "future", 1, outcome(3, 1)), "Wrong round rejected")
	check(not safe:settleRound("safe", safeId, 0 / 0, outcome(3, 1)), "Nonfinite sequence rejected")
	check(not safe:settleRound("safe", safeId, 1, { { id = "p1", alive = true } }), "Incomplete roster rejected")
	check(not safe:settleRound("safe", safeId, 1, {
		{ id = "p1", alive = true },
		{ id = "p1", alive = false, placement = 2 },
		{
			id = "p3",
			alive = false,
			placement = 3,
		},
	}), "Duplicate player rejected")
	check(not safe:settleRound("safe", safeId, 1, {
		{ id = "p1", alive = true },
		{ id = "p2", alive = false, placement = 1 },
		{
			id = "p3",
			alive = false,
			placement = 3,
		},
	}), "Impossible placement batch rejected")
	check(#safe.history == 0 and safe.byId.p1.score == 0, "Invalid events cannot partially mutate totals")
	check(safe:settleRound("safe", safeId, 5, outcome(3, 1)), "Valid sequence accepted after rejection")
	local _, safeNext = safe:beginRound()
	check(not safe:settleRound("safe", safeNext, 4, outcome(3, 1)), "Delayed prior sequence rejected")
	local snap = safe:snapshot()
	snap.players[1].score = 999
	snap.ledger.awards[1].total = 999
	check(safe.byId.p1.score == 3 and safe.history[1].awards[1].total == 3, "Snapshots cannot mutate authority")
	local left = Series.new("left", roster(3))
	local _, leftId = left:beginRound()
	left:disconnect("p3")
	check(left:settleRound("left", leftId, 1, outcome(3, 1)), "Current outcome includes disconnected core")
	check(left.byId.p3.score == 0, "Departed player receives no current-round points")
	left:beginRound()
	check(#left.activeIds == 2, "Disconnected player excluded from next round roster")
	left:disconnect("p2")
	check(
		left.phase == "Final" and left.reason == "Abandoned" and #left.winnerIds == 0,
		"Too few competitors ends without competitive winner/reward"
	)
	check(
		not left:settleRound("left", left.activeRoundId, 9, outcome(2, 1)),
		"Canceled round cannot settle after abandonment"
	)
	check(not pcall(function()
		Series.new("bad", roster(1))
	end), "Unsupported roster rejected")
	check(not pcall(function()
		Series.new("bad", roster(2), { MaxOvertimes = math.huge })
	end), "Unbounded overtime rejected")
	check(not pcall(function()
		Series.new("bad", roster(2), { Mode = "Unknown" })
	end), "Unknown ruleset rejected")
	print(string.format("ISOLATED MATCH SERIES: %d assertions; original proposed rules, no runtime bootstrap", passed))
	return { passed = passed, failed = 0 }
end
