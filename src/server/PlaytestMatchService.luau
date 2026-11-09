--!strict
local Shared = game:GetService("ReplicatedStorage").TrailWars
local Round = require(Shared.RoundSession)
local Series = require(Shared.MatchSeries)
local Powers = require(Shared.PowerService)
local Match = {}
Match.__index = Match
function Match.new(namespace: string, callbacks: any?, testConfig: any?)
	return setmetatable({
		namespace = namespace,
		callbacks = callbacks or {},
		members = {},
		queue = {},
		settings = { target = 40, rounds = 5, overtime = true, turrets = true },
		tick = 0,
		serial = 0,
		revision = 0,
		phase = "Queue",
		wait = 0,
		config = testConfig or {},
		hits = {},
		log = {},
		settlements = 0,
	}, Match)
end
function Match:add(id: string, name: string)
	self.members[id] = { id = id, name = name, sequence = 0, turn = 0, lease = 0, budget = 0, window = -1 }
	self.hostId = self.hostId or id
end
function Match:_leave(id: string)
	if self.series and self.series.byId[id] and self.series.byId[id].connected and self.phase ~= "Final" then
		if self.round and not self.round.finalized and self.delta[id] and self.callbacks.round then
			self.callbacks.round(id, self.round.matchId, table.clone(self.delta[id]))
		end
		if self.callbacks.match then
			self.callbacks.match(id, self.series.matchId, false)
		end
		self.series:disconnect(id)
	end
	if self.round then
		Round.remove(self.round, id)
		local p = self.round.sim.byId[id]
		if p then
			p.cause = "Left"
			p.jumping = false
		end
		if self.powers then
			local keep = {}
			for _, q in self.powers.projectiles do
				if q.owner ~= id then
					table.insert(keep, q)
				end
			end
			self.powers.projectiles = keep
		end
	end
end
function Match:remove(id: string)
	self.queue[id] = nil
	self:_leave(id)
	self.members[id] = nil
	if id == self.hostId then
		self.hostId = nil
		for key in self.members do
			self.hostId = key
			break
		end
	end
end
function Match:request(id: string, m: any): (boolean, string)
	local member = self.members[id]
	if not member or type(m) ~= "table" then
		return false, "PLAYER"
	end
	local window = math.floor(self.tick / 50)
	if window ~= member.window then
		member.budget = 0
		member.window = window
	end
	member.budget += 1
	if member.budget > 40 then
		return false, "RATE"
	end
	for key in m do
		if
			key ~= "action"
			and key ~= "sequence"
			and key ~= "matchId"
			and key ~= "roundId"
			and key ~= "turn"
			and key ~= "slot"
			and key ~= "settings"
		then
			return false, "FIELD"
		end
	end
	if
		type(m.sequence) ~= "number"
		or m.sequence ~= m.sequence
		or m.sequence % 1 ~= 0
		or m.sequence <= member.sequence
		or m.sequence > 2147483647
	then
		return false, "SEQUENCE"
	end
	if
		m.action ~= "Join"
		and m.action ~= "Leave"
		and m.action ~= "Rematch"
		and m.action ~= "Steer"
		and m.action ~= "Activate"
		and m.action ~= "Configure"
		and m.action ~= "Resync"
	then
		return false, "ACTION"
	end
	member.sequence = m.sequence
	if m.action == "Join" or m.action == "Rematch" then
		if self.phase == "Final" and not next(self.queue) then
			self.rematchWait = 0
		end
		self.queue[id] = true
		return true, "QUEUED"
	elseif m.action == "Leave" then
		self.queue[id] = nil
		self:_leave(id)
		return true, "LEFT"
	elseif m.action == "Configure" then
		if id ~= self.hostId or (self.phase ~= "Queue" and self.phase ~= "Final") or type(m.settings) ~= "table" then
			return false, "HOST"
		end
		local s = m.settings
		for key in s do
			if key ~= "target" and key ~= "rounds" and key ~= "overtime" and key ~= "turrets" then
				return false, "SETTING"
			end
		end
		if
			(s.target ~= 30 and s.target ~= 40 and s.target ~= 80)
			or (s.rounds ~= 3 and s.rounds ~= 5)
			or type(s.overtime) ~= "boolean"
			or type(s.turrets) ~= "boolean"
		then
			return false, "SETTING"
		end
		self.settings = table.clone(s)
		return true, "CONFIGURED"
	elseif m.action == "Resync" then
		if self.tick - (member.resyncTick or -1000) < 50 then
			return false, "RATE"
		end
		member.resyncTick = self.tick
		return true, "RESYNC"
	end
	if
		self.phase ~= "Active"
		or not self.series
		or m.matchId ~= self.series.matchId
		or m.roundId ~= self.round.matchId
	then
		return false, "ROUND"
	end
	local p = self.round.sim.byId[id]
	if not p or p.cause == "Left" or not self.series.byId[id].connected then
		return false, "SPECTATOR"
	end
	if m.action == "Steer" then
		if m.turn ~= -1 and m.turn ~= 0 and m.turn ~= 1 then
			return false, "TURN"
		end
		member.turn = m.turn
		member.lease = self.tick + 20
		return true, "STEERING"
	end
	if m.slot ~= "Homing" and m.slot ~= "Jump" then
		return false, "SLOT"
	end
	return self.powers:activate(id, m.slot, m.roundId)
end
function Match:_beginRound()
	local ok, id = self.series:beginRound()
	if not ok then
		self.phase = "Final"
		return
	end
	local roster = {}
	self.roundStart = {}
	self.delta = {}
	self.deathEvent = 0
	self.hits = {}
	for _, p in self.series.players do
		if p.connected then
			table.insert(roster, { id = p.id, name = p.name, isBot = string.sub(p.id, 1, 3) == "bot" })
			self.roundStart[p.id] = p.score
			self.delta[p.id] = {
				roundsPlayed = 1,
				roundsWon = 0,
				kills = 0,
				deaths = 0,
				powerHits = 0,
				turretHits = 0,
				scoreStolen = 0,
			}
		end
	end
	self.round = Round.new(roster, self.config, id)
	self.powers = Powers.new(self.round.sim, id, self.settings.turrets, function(hitId, owner, victim, amount, kind)
		if self.phase ~= "Active" or self.hits[hitId] then
			return
		end
		self.hits[hitId] = true
		local source, target = self.series.byId[owner], self.series.byId[victim]
		if not source or not target or not source.connected then
			return
		end
		local taken = math.min(amount, target.score)
		target.score -= taken
		source.score += taken
		local d = self.delta[owner]
		if d then
			d[if kind == "Turret" then "turretHits" else "powerHits"] += 1
			d.scoreStolen += taken
		end
		table.insert(
			self.log,
			{ kind = kind, owner = owner, victim = victim, points = taken, roundId = id, tick = self.tick }
		)
	end)
	self.phase = "Countdown"
	self.wait = 0
	for _, m in self.members do
		m.turn = 0
		m.lease = 0
	end
end
function Match:_start()
	local ids = {}
	for id in self.queue do
		if self.members[id] then
			table.insert(ids, id)
		end
	end
	table.sort(ids)
	if #ids == 0 then
		return
	end
	local roster = {}
	for i = 1, math.min(6, #ids) do
		local m = self.members[ids[i]]
		table.insert(roster, { id = m.id, name = m.name })
		self.queue[m.id] = nil
	end
	for i = #roster + 1, 4 do
		table.insert(roster, { id = "bot" .. i, name = "BOT " .. i })
	end
	self.serial += 1
	self.series = Series.new(self.namespace .. ":m" .. self.serial, roster, {
		Mode = "Sprint",
		Target = self.settings.target,
		MaxRounds = self.settings.rounds,
		MinRounds = 3,
		PointValue = 10,
		WinnerBonus = 0,
		MaxOvertimes = if self.settings.overtime then 1 else 0,
	})
	for _, p in self.series.players do
		p.score = 10
	end
	self.log = {}
	self:_beginRound()
end
function Match:_settle()
	if self.round.finalized then
		return
	end
	self.round.finalized = true
	self.powers:close()
	local rows = {}
	for _, p in self.round.sim.players do
		table.insert(rows, { id = p.id, alive = p.alive, placement = p.placement })
		if p.id == self.round.sim.winnerId then
			self.delta[p.id].roundsWon = 1
		end
	end
	local ok, code = self.series:settleRound(self.series.matchId, self.round.matchId, self.tick, rows)
	assert(ok, "Authoritative round settlement: " .. code)
	self.settlements += 1
	local ledger = self.series.history[#self.series.history]
	for _, award in ledger.awards do
		award.before = self.roundStart[award.id]
		award.delta = award.total - award.before
	end
	if self.callbacks.round then
		for id, d in self.delta do
			if self.members[id] then
				self.callbacks.round(id, self.round.matchId, table.clone(d))
			end
		end
	end
	if self.series.phase == "Final" then
		self.phase = "Final"
		if self.callbacks.match and not self.finalizedSeries then
			self.finalizedSeries = self.series.matchId
			for _, p in self.series.players do
				if self.members[p.id] and p.connected then
					self.callbacks.match(p.id, self.series.matchId, table.find(self.series.winnerIds, p.id) ~= nil)
				end
			end
		end
	else
		self.phase = "Intermission"
	end
	self.wait = 0
end
function Match:step()
	self.tick += 1
	self.revision += 1
	self.wait += 0.02
	if self.phase == "Queue" then
		if not next(self.queue) then
			self.wait = 0
			return
		end
		if
			next(self.queue)
			and (
				self.wait >= 8
				or self.wait >= 2
					and (function()
						local n = 0
						for _ in self.queue do
							n += 1
						end
						return n >= 2
					end)()
			)
		then
			self:_start()
		end
		return
	end
	if self.phase == "Final" then
		if next(self.queue) then
			self.rematchWait = (self.rematchWait or 0) + 0.02
		end
		local queued = 0
		for _ in self.queue do
			queued += 1
		end
		if next(self.queue) and ((queued >= 2 and (self.rematchWait or 0) >= 2) or (self.rematchWait or 0) >= 8) then
			self.finalizedSeries = nil
			self:_start()
		end
		return
	end
	if self.series.phase == "Final" and self.series.reason == "Abandoned" then
		self.powers:close()
		self.phase = "Final"
		return
	end
	if self.phase == "Intermission" then
		if self.wait >= (self.config.IntermissionSeconds or 4) then
			self:_beginRound()
		end
		return
	end
	local r = self.round
	for id, m in self.members do
		r.inputs[id] = if self.tick <= m.lease then m.turn else 0
	end
	if self.phase == "Active" then
		self.powers:before(r.inputs)
		for _, p in r.sim.players do
			if self.config.BotPowers ~= false and p.isBot and p.alive and self.powers.tick % 100 == 0 then
				self.powers:activate(p.id, if self.powers.tick % 200 == 0 then "Jump" else "Homing", r.matchId)
			end
		end
	end
	Round.step(r)
	self.phase = r.phase
	for i = self.deathEvent + 1, #r.sim.events do
		local e = r.sim.events[i]
		local d = self.delta[e.id]
		if d then
			d.deaths += 1
		end
		if e.killerId and e.killerId ~= e.id and self.delta[e.killerId] then
			self.delta[e.killerId].kills += 1
		end
		table.insert(self.log, {
			kind = "Eliminated",
			victim = e.id,
			owner = e.killerId,
			cause = e.cause,
			roundId = r.matchId,
			tick = self.tick,
		})
	end
	self.deathEvent = #r.sim.events
	if r.phase == "Results" then
		self:_settle()
	elseif self.phase == "Active" then
		self.powers:after()
	end
end
function Match:snapshot()
	local state = if self.round
		then Round.snapshot(self.round)
		else { players = {}, time = 0, tick = 0, remaining = 0, segmentCount = 0, matchId = "queue" }
	state.phase = self.phase
	state.revision = self.revision
	state.playtest = true
	state.settings = table.clone(self.settings)
	state.hostId = self.hostId
	state.seriesId = if self.series then self.series.matchId else ""
	state.roundId = state.matchId
	state.series = if self.series then self.series:snapshot() else nil
	state.roundWinnerId = state.winnerId
	if self.phase == "Final" and self.series then
		state.winnerIds = table.clone(self.series.winnerIds)
		state.winnerId = if #self.series.winnerIds == 1 then self.series.winnerIds[1] else nil
		state.reason = self.series.reason
	end
	state.powers = if self.powers then self.powers:snapshot() else { actors = {}, projectiles = {} }
	state.intermission = math.max(0, math.ceil((self.config.IntermissionSeconds or 4) - self.wait))
	return state
end
return Match
