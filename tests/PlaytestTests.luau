--!strict
return function()
	local R = game:GetService("ReplicatedStorage").TrailWars
	local S = game:GetService("ServerScriptService").TrailWars
	local Sim = require(R.Simulation)
	local Power = require(R.PowerService)
	local Stats = require(R.PlaytestStats)
	local Schema = require(R.ProfileSchema)
	local Profiles = require(S.ProfileStore)
	local Store = require(S.MockStore)
	local Match = require(S.PlaytestMatchService)
	local n = 0
	local function check(v: boolean, msg: string)
		assert(v, msg)
		n += 1
	end
	local function fixture()
		return Sim.new({
			{ id = "a", x = 100, y = 100, heading = 0 },
			{ id = "b", x = 700, y = 500, heading = 0 },
			{
				id = "c",
				x = 1000,
				y = 700,
				heading = 0,
			},
		}, { RampSeconds = 0, Speed = 100, MaxRoundSeconds = 60 })
	end
	local s = fixture()
	s.index:insert({ owner = "b", ax = 170, ay = 80, bx = 170, by = 120, endDistance = 100 })
	local p = Power.new(s, "r1", true, function() end)
	check(not p:activate("a", "Jump", "r1"), "Initial cooldown enforced")
	for _ = 1, 25 do
		p:before({})
		Sim.step(s, {})
		p:after()
	end
	check(p:activate("a", "Jump", "r1"), "Jump activation after initial cooldown")
	check(not p:activate("a", "Jump", "r1"), "Double activation blocked")
	for _ = 1, 24 do
		p:before({})
		Sim.step(s, {})
		p:after()
	end
	check(s.byId.a.alive and s.byId.a.x > 190 and not s.byId.a.jumping, "Jump traverses lethal trail and expires")
	local beforeEnd, afterStart = nil, nil
	for _, seg in s.index.segments do
		if seg.owner == "a" then
			if seg.bx <= 150.01 then
				beforeEnd = seg.bx
			elseif not afterStart then
				afterStart = seg.ax
			end
		end
	end
	check(
		beforeEnd ~= nil and afterStart ~= nil and afterStart - beforeEnd > 35,
		"Jump creates a real authoritative trail gap"
	)
	local lethal = fixture()
	lethal.index:insert({ owner = "b", ax = 110, ay = 80, bx = 110, by = 120, endDistance = 100 })
	Sim.step(lethal, {})
	check(not lethal.byId.a.alive and lethal.byId.a.killerId == "b", "Enemy trail lethal event carries real owner")
	local wall = fixture()
	wall.byId.a.x = 1290
	wall.byId.a.jumping = true
	for _ = 1, 5 do
		Sim.step(wall, {})
	end
	check(not wall.byId.a.alive and wall.byId.a.killerId == nil, "Jump never grants wall immunity or wall kill credit")
	local selfHit = fixture()
	selfHit.byId.a.distance = 100
	selfHit.index:insert({ owner = "a", ax = 110, ay = 80, bx = 110, by = 120, endDistance = 10 })
	Sim.step(selfHit, {})
	check(not selfHit.byId.a.alive and selfHit.byId.a.killerId == nil, "Self-collision is a death, not a kill")
	local shots = fixture()
	shots.byId.b.x = 160
	shots.byId.b.y = 100
	local hitCount = 0
	local hitKind = nil
	local attack = Power.new(shots, "shots", true, function(_, _, _, _, kind)
		hitCount += 1
		hitKind = kind
	end)
	attack.actors.a.ready.Homing = 0
	check(attack:activate("a", "Homing", "shots"), "Homing fires server projectile")
	check(not attack:activate("a", "Homing", "shots"), "Homing cooldown rejects turbo-fire")
	check(not attack:activate("a", "Unknown", "shots"), "Invalid slot rejected")
	check(not attack:activate("a", "Jump", "old"), "Old round power rejected")
	for _ = 1, 50 do
		attack:before({})
		attack:after()
	end
	check(hitCount == 1 and hitKind == "Homing" and shots.byId.b.alive, "Projectile hits exactly once and is nonlethal")
	local homing = fixture()
	homing.byId.b.x = 160
	homing.byId.b.y = 140
	local seeker = Power.new(homing, "seek", true, function() end)
	seeker.actors.a.ready.Homing = 0
	seeker:activate("a", "Homing", "seek")
	seeker:before({})
	seeker:after()
	check(seeker.projectiles[1].heading > 0, "Homing changes heading toward target")
	local rockets = fixture()
	rockets.byId.a.alive = false
	rockets.byId.a.cause = "Trail"
	rockets.byId.b.x = 200
	rockets.byId.b.y = 100
	local rocketHits = 0
	local turret = Power.new(rockets, "turret", true, function(_, _, _, _, kind)
		if kind == "Turret" then
			rocketHits += 1
		end
	end)
	for _ = 1, 70 do
		turret:before({ a = 0 })
		turret:after()
	end
	check(rocketHits == 1 and not rockets.byId.a.alive, "Eliminated player launches a distinct nonlethal turret rocket")
	check(not turret:activate("a", "Homing", "turret"), "Dead player cannot fire equipped power")
	turret.actors.a.nextRocket = turret.tick
	turret:before({ a = 1 })
	turret:after()
	check(#turret.projectiles == 1 and turret.projectiles[1].heading > 0, "Dead player's steering controls its rocket")
	rockets.phase = "Results"
	turret:after()
	check(turret.closed and #turret.projectiles == 0, "Round finalization cancels all rockets before late hits")
	check(not turret:activate("b", "Jump", "turret"), "Closed round cannot activate abilities")
	local off = Power.new(fixture(), "off", false, function() end)
	off.sim.byId.a.alive = false
	for _ = 1, 200 do
		off:before({})
		off:after()
	end
	check(
		#off.projectiles == 0 and off:snapshot().actors.a.state == "Spectator",
		"Disabled turret uses spectator fallback"
	)
	local profile = Schema.new()
	profile.coins = 123
	profile.stats.rounds = 7
	profile.stats.wins = 2
	check(Stats.ensure(profile), "Safe additive legacy migration")
	check(
		profile.coins == 123
			and profile.stats.wins == 2
			and profile.playtest.stats.roundsWon == 2
			and profile.playtest.stats.matchesWon == 0,
		"Migration preserves legacy economy and does not relabel round wins as match wins"
	)
	check(
		Stats.round(
			profile,
			"r",
			{ roundsPlayed = 1, kills = 1, deaths = 0, powerHits = 3, turretHits = 2, scoreStolen = 5 }
		),
		"Authoritative stats round stored"
	)
	Stats.round(profile, "r", { kills = 999 })
	check(
		profile.playtest.stats.kills == 1 and profile.playtest.stats.powerHits == 3,
		"Duplicate round cannot award twice; hits stay separate from kills"
	)
	Stats.match(profile, "m", true)
	Stats.match(profile, "m", true)
	check(
		profile.playtest.stats.matchesWon == 1 and profile.playtest.stats.matchesPlayed == 1,
		"Match wins settled once"
	)
	Stats.time(profile, "session", 61)
	Stats.time(profile, "session", 61)
	Stats.time(profile, "session", 20)
	Stats.time(profile, "session", 70)
	Stats.time(profile, "reconnect", 10)
	check(profile.playtest.stats.totalPlaySeconds == 80, "Elapsed checkpoints and reconnect cannot double count time")
	check(Stats.format(3661) == "1h 01m", "Hours/minutes derive from seconds")
	check(not Stats.round(profile, "bad", { kills = 0 / 0 }), "Invalid stat delta rejected")
	local future = Schema.new()
	future.playtest = { version = 999 }
	check(not Stats.ensure(future), "Future extension never overwritten")
	local store = Store.new()
	local a = Profiles.new(store, function()
		return 100
	end, "first")
	a:load(12)
	a:transact(12, function(x)
		return Stats.ensure(x)
	end)
	store.fail = true
	check(not a:transact(12, function(x)
		return Stats.time(x, "clock", 30)
	end), "Save failure reported")
	store.fail = false
	check(a:snapshot(12) == nil, "Uncertain write hides stale time totals")
	check(a:load(12), "Reconcile after failed save before replaying idempotent session time")
	a:transact(12, function(x)
		return Stats.time(x, "clock", 30)
	end)
	a:release(12)
	local b = Profiles.new(store, function()
		return 101
	end, "second")
	b:load(12)
	check(
		b:snapshot(12).playtest.stats.totalPlaySeconds == 30,
		"Reconnect retains successful mock save without failed-write duplication"
	)
	local rounds, matches = 0, 0
	local m = Match.new("integration", {
		round = function()
			rounds += 1
		end,
		match = function()
			matches += 1
		end,
	}, { CountdownSeconds = 0.02, MaxRoundSeconds = 0.2, IntermissionSeconds = 0.02 })
	m:add("u1", "ONE")
	m:add("u2", "TWO")
	check(
		m:request("u1", {
			action = "Configure",
			sequence = 1,
			settings = { target = 30, rounds = 3, overtime = false, turrets = true },
		}),
		"Host can adjust visible playtest rules"
	)
	check(not m:request("u2", {
		action = "Configure",
		sequence = 1,
		settings = { target = 30, rounds = 3, overtime = false, turrets = true },
	}), "Non-host cannot change rules")
	m:request("u1", { action = "Join", sequence = 2 })
	m:request("u2", { action = "Join", sequence = 2 })
	for _ = 1, 250 do
		m:step()
	end
	check(
		m.phase == "Final" and m.series.round == 3 and m.settlements == 3,
		"Integrated power match guarantees three finite rounds"
	)
	check(rounds == 6 and matches == 2, "Two humans receive each round and exactly one final match result")
	local old = m.series.matchId
	m:request("u1", { action = "Rematch", sequence = 3 })
	m:request("u2", { action = "Rematch", sequence = 3 })
	for _ = 1, 150 do
		m:step()
	end
	check(m.series.matchId ~= old, "Rematch creates a new series identity")
	local extraHits = 0
	local moving = fixture()
	moving.byId.b.x = 500
	moving.byId.b.y = 280
	local swept = Power.new(moving, "moving", false, function()
		extraHits += 1
	end)
	swept.actors.a.ready.Homing = 0
	swept:activate("a", "Homing", "moving")
	swept.projectiles[1].x = 500
	swept.projectiles[1].y = 300
	swept:before({})
	moving.byId.b.y = 320
	swept:after()
	check(extraHits == 1, "Projectile sweep includes target motion across its path")
	local expired = Power.new(fixture(), "expired", false, function()
		extraHits += 1
	end)
	expired.actors.a.ready.Homing = 0
	expired:activate("a", "Homing", "expired")
	expired.projectiles[1].expires = 1
	expired:before({})
	expired:after()
	check(#expired.projectiles == 0 and extraHits == 1, "Expiry happens before a last-tick contact")
	local cleaned = Power.new(fixture(), "death-clean", false, function() end)
	cleaned.actors.a.ready.Homing = 0
	cleaned:activate("a", "Homing", "death-clean")
	cleaned.sim.byId.a.alive = false
	cleaned:before({})
	cleaned:after()
	check(#cleaned.projectiles == 0, "Death cancels remaining equipped projectiles")
	local departed = Schema.new()
	Stats.ensure(departed)
	local offline = Match.new("offline", {
		round = function(id, event, d)
			if id == "u1" then
				Stats.round(departed, event, d)
			end
		end,
		match = function(id, event, won)
			if id == "u1" then
				Stats.match(departed, event, won)
			end
		end,
	}, { CountdownSeconds = 0.02, RampSeconds = 0, Speed = 1000 })
	offline:add("u1", "ONE")
	offline:add("u2", "TWO")
	offline:request("u1", { action = "Join", sequence = 1 })
	offline:request("u2", { action = "Join", sequence = 1 })
	for _ = 1, 105 do
		offline:step()
	end
	local target = offline.round.sim.byId.u2
	target.x = 100
	target.y = 100
	target.heading = 0
	offline.round.sim.index:insert({ owner = "u1", ax = 110, ay = 80, bx = 110, by = 120, endDistance = 10 })
	offline:remove("u1")
	offline:step()
	check(
		departed.playtest.stats.matchesLost == 1 and departed.playtest.stats.matchesPlayed == 1,
		"Leaving counts exactly one match forfeit"
	)
	check(departed.playtest.stats.kills == 1, "A lingering owned trail still credits its departed owner")
	offline:add("u1", "REJOIN")
	check(not offline:request("u1", {
		action = "Steer",
		sequence = 1,
		matchId = offline.series.matchId,
		roundId = offline.round.matchId,
		turn = 1,
	}), "Reconnect cannot steer a forfeited old turret")
	print(string.format("NOV10 PLAYTEST: %d assertions; pure engine/powers/stats integration", n))
	return { passed = n, failed = 0 }
end
