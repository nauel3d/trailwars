--!strict
-- Deterministic ART REVIEW fixture. Executes the real round, collision and power modules.
local Round = require(script.Parent.RoundSession)
local Powers = require(script.Parent.PowerService)
local Config = require(script.Parent.GameplayConfig)
local Replay = {}
function Replay.new()
	local config = table.clone(Config)
	config.CountdownSeconds = 0
	config.MaxRoundSeconds = 60
	local roster = {
		{ id = "comet", name = "COMET", x = 250, y = 430, heading = 0 },
		{ id = "orbit", name = "ORBIT", x = 540, y = 430, heading = math.pi },
		{ id = "sunny", name = "SUNNY", x = 590, y = 530, heading = -0.5, isBot = true },
		{ id = "mint", name = "MINT", x = 860, y = 280, heading = 1.5, isBot = true },
		{ id = "plum", name = "PLUM", x = 930, y = 570, heading = 3, isBot = true },
		{ id = "tango", name = "TANGO", x = 400, y = 190, heading = 0, isBot = true },
	}
	local r = Round.new(roster, config, "candy-review")
	local replay: any = { round = r, tick = 0, events = {}, deaths = 0, activations = {}, scores = {} }
	for _, p in roster do
		replay.scores[p.id] = 10
	end
	local function event(kind, victim, cause)
		local p = r.sim.byId[victim]
		table.insert(
			replay.events,
			{ sequence = #replay.events + 1, kind = kind, victim = victim, x = p.x, y = p.y, cause = cause }
		)
	end
	replay.powers = Powers.new(r.sim, r.matchId, true, function(_id, owner, victim, amount, kind)
		local taken = math.min(amount, replay.scores[victim])
		replay.scores[victim] -= taken
		replay.scores[owner] += taken
		event(kind, victim, nil)
	end)
	r.sim.index:insert({ owner = "orbit", ax = 300, ay = 390, bx = 300, by = 465, endDistance = 0 })
	r.sim.index:insert({ owner = "comet", ax = 500, ay = 395, bx = 500, by = 465, endDistance = 0 })
	function replay:step()
		replay.tick += 1
		if r.phase == "Active" then
			if replay.tick == 28 then
				replay.activations.Jump = replay.powers:activate("comet", "Jump", r.matchId)
			end
			if replay.tick == 52 then
				replay.activations.Homing = replay.powers:activate("comet", "Homing", r.matchId)
			end
			if replay.tick > 100 and r.sim.byId.comet.alive then
				r.inputs.comet = -0.25
			end
			replay.powers:before(r.inputs)
		end
		Round.step(r)
		for i = replay.deaths + 1, #r.sim.events do
			local e = r.sim.events[i]
			event("Eliminated", e.id, e.cause)
		end
		replay.deaths = #r.sim.events
		if r.phase == "Active" then
			replay.powers:after()
		else
			replay.powers:close()
		end
	end
	function replay:snapshot()
		local s = Round.snapshot(r)
		s.roundId = r.matchId
		s.settings = { target = 40 }
		s.powers = replay.powers:snapshot()
		s.visualEvents = replay.events
		local players = {}
		for _, p in roster do
			players[#players + 1] = { id = p.id, name = p.name, score = replay.scores[p.id] }
		end
		table.sort(players, function(a, b)
			return if a.score == b.score then a.id < b.id else a.score > b.score
		end)
		local rank = 1
		for i, p in players do
			if i > 1 and p.score ~= players[i - 1].score then
				rank = i
			end
			p.rank = rank
		end
		s.series = { round = 1, players = players, winnerIds = {} }
		return s
	end
	return replay
end
return Replay
