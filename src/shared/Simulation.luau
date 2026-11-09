--!strict
local Geometry = require(script.Parent.Geometry)
local Index = require(script.Parent.TrailIndex)
local Defaults = require(script.Parent.GameplayConfig)
local Sim = {}
function Sim.motion(player: any, turn: number, dt: number, config: any, time: number)
	local fraction = 1
	if config.RampSeconds > 0 then
		fraction = math.clamp((time + dt * 0.5) / config.RampSeconds, 0, 1)
	end
	local speed = config.Speed * fraction
	local omega = turn * config.TurnRate
	local heading = player.heading + omega * dt
	local x, y = player.x, player.y
	if math.abs(omega) < 1e-9 then
		x += math.cos(player.heading) * speed * dt
		y += math.sin(player.heading) * speed * dt
	else
		local radius = speed / omega
		x += radius * (math.sin(heading) - math.sin(player.heading))
		y -= radius * (math.cos(heading) - math.cos(player.heading))
	end
	return {
		x = x,
		y = y,
		heading = math.atan2(math.sin(heading), math.cos(heading)),
		distance = player.distance + speed * dt,
	}
end
-- Conservative chord envelope; the production 20ms bound is below 0.025 units.
function Sim.sweepMargin(turn: number, dt: number, c: any, time: number): number
	local arc = 0
	if turn ~= 0 and c.TurnRate > 1e-9 then
		arc = c.Speed / c.TurnRate * (1 - math.cos(math.min(math.pi, c.TurnRate * dt) * 0.5))
	end
	local ramp = if c.RampSeconds > 0 and time < c.RampSeconds then c.Speed / c.RampSeconds * dt * dt / 8 else 0
	return arc + ramp
end
function Sim.new(roster: any, overrides: any?)
	local config = table.clone(Defaults)
	for key, value in overrides or {} do
		config[key] = value
	end
	local self: any = {
		config = config,
		players = {},
		byId = {},
		index = Index.new(config.CellSize),
		tick = 0,
		time = 0,
		events = {},
		phase = "Active",
		reason = nil,
		nextEvent = 0,
	}
	for i, item in roster do
		assert(type(item.id) == "string" and not self.byId[item.id], "Players require unique stable IDs")
		local angle = 2 * math.pi * (i - 1) / #roster
		local p = {
			id = item.id,
			name = item.name or item.id,
			isBot = item.isBot == true,
			x = item.x or config.Width * (0.5 + 0.31 * math.cos(angle)),
			y = item.y or config.Height * (0.5 + 0.31 * math.sin(angle)),
			heading = item.heading or angle + math.pi,
			distance = 0,
			alive = true,
			turn = 0,
			trailCount = 0,
			placement = nil,
		}
		self.players[i] = p
		self.byId[p.id] = p
	end
	return self
end
function Sim.alive(self: any): number
	local count = 0
	for _, p in self.players do
		if p.alive then
			count += 1
		end
	end
	return count
end
function Sim.step(self: any, inputs: any?)
	if self.phase ~= "Active" then
		return
	end
	local c = self.config
	local remaining = c.Step
	local elapsed = 0
	local iterations = 0
	self.tick += 1
	while remaining > 1e-8 do
		iterations += 1
		assert(iterations <= #self.players + 1, "Collision event solver must make progress")
		local proposals = {}
		local margins = {}
		local hits = {}
		local earliest = 1 + 1e-7
		local function hit(t: number?, id: string, kind: string, other: string?)
			if not t then
				return
			end
			if t < earliest - 1e-7 then
				earliest = t
				table.clear(hits)
			end
			if math.abs(t - earliest) <= 1e-7 then
				table.insert(hits, { id = id, kind = kind, other = other })
			end
		end
		for _, p in self.players do
			if p.alive then
				local turn = if inputs and inputs[p.id] ~= nil then inputs[p.id] else p.turn
				p.turn = if turn == -1 or turn == 1 then turn else 0
				local nextState = Sim.motion(p, p.turn, remaining, c, self.time + elapsed)
				proposals[p.id] = nextState
				local margin = Sim.sweepMargin(p.turn, remaining, c, self.time + elapsed)
				margins[p.id] = margin
				hit(
					Geometry.wallTOI(p.x, p.y, nextState.x, nextState.y, c.Width, c.Height, c.CoreRadius + margin),
					p.id,
					"Wall"
				)
				if not p.jumping then
					for _, segment in
						self.index:query(p.x, p.y, nextState.x, nextState.y, c.CoreRadius + c.TrailRadius + margin)
					do
						if segment.owner ~= p.id or p.distance - segment.endDistance > c.SelfGraceDistance then
							hit(
								Geometry.capsuleTOI(
									p.x,
									p.y,
									nextState.x,
									nextState.y,
									segment.ax,
									segment.ay,
									segment.bx,
									segment.by,
									c.CoreRadius + c.TrailRadius + margin
								),
								p.id,
								if segment.owner == p.id then "SelfTrail" else "Trail",
								segment.owner
							)
						end
					end
				end
			end
		end
		for i, a in self.players do
			if a.alive then
				for j = i + 1, #self.players do
					local b = self.players[j]
					if b.alive and not a.jumping and not b.jumping then
						local an, bn = proposals[a.id], proposals[b.id]
						local head = Geometry.circleTOI(
							a.x - b.x,
							a.y - b.y,
							an.x - bn.x,
							an.y - bn.y,
							0,
							0,
							c.CoreRadius * 2 + margins[a.id] + margins[b.id]
						)
						hit(head, a.id, "Core", b.id)
						hit(head, b.id, "Core", a.id)
						hit(
							Geometry.growingTOI(
								a.x,
								a.y,
								an.x,
								an.y,
								b.x,
								b.y,
								bn.x,
								bn.y,
								c.CoreRadius + c.TrailRadius + margins[a.id] + margins[b.id]
							),
							a.id,
							"Trail",
							b.id
						)
						hit(
							Geometry.growingTOI(
								b.x,
								b.y,
								bn.x,
								bn.y,
								a.x,
								a.y,
								an.x,
								an.y,
								c.CoreRadius + c.TrailRadius + margins[a.id] + margins[b.id]
							),
							b.id,
							"Trail",
							a.id
						)
					end
				end
			end
		end
		local portion = math.min(earliest, 1)
		for _, p in self.players do
			if p.alive then
				local proposed = proposals[p.id]
				local angle = math.atan2(math.sin(proposed.heading - p.heading), math.cos(proposed.heading - p.heading))
				local n = {
					x = p.x + (proposed.x - p.x) * portion,
					y = p.y + (proposed.y - p.y) * portion,
					heading = p.heading + angle * portion,
					distance = p.distance + (proposed.distance - p.distance) * portion,
				}
				if not p.jumping and (n.x - p.x) ^ 2 + (n.y - p.y) ^ 2 > 1e-12 then
					self.index:insert({
						owner = p.id,
						ax = p.x,
						ay = p.y,
						bx = n.x,
						by = n.y,
						startDistance = p.distance,
						endDistance = n.distance,
						tick = self.tick,
					})
					p.trailCount += 1
				end
				p.x, p.y, p.heading, p.distance = n.x, n.y, n.heading, n.distance
			end
		end
		elapsed += remaining * portion
		remaining *= 1 - portion
		if earliest <= 1 then
			local before = Sim.alive(self)
			local killed = {}
			for _, event in hits do
				local p = self.byId[event.id]
				if p.alive and not killed[p.id] then
					killed[p.id] = true
					p.alive = false
					p.placement = before
					p.eliminatedTick = self.tick
					p.cause = event.kind
					p.killerId = if event.kind == "Trail" and event.other ~= p.id then event.other else nil
					self.nextEvent += 1
					table.insert(self.events, {
						sequence = self.nextEvent,
						tick = self.tick,
						id = p.id,
						kind = "Eliminated",
						cause = event.kind,
						killerId = p.killerId,
						placement = before,
					})
				end
			end
		end
		if Sim.alive(self) <= 1 then
			self.phase = "Results"
			for _, p in self.players do
				if p.alive then
					self.winnerId = p.id
					p.placement = 1
				end
			end
			self.reason = if self.winnerId then "LastAlive" else "Draw"
			break
		end
		if #self.index.segments >= c.MaxSegments then
			self.phase = "Results"
			self.reason = "GeometryLimit"
			break
		end
	end
	self.time += c.Step
	if self.time >= c.MaxRoundSeconds and self.phase == "Active" then
		self.phase = "Results"
		self.reason = "TimeLimit"
	end
end
function Sim.snapshot(self: any)
	local players = {}
	for _, p in self.players do
		table.insert(players, {
			id = p.id,
			name = p.name,
			isBot = p.isBot,
			x = p.x,
			y = p.y,
			heading = p.heading,
			distance = p.distance,
			alive = p.alive,
			turn = p.turn,
			placement = p.placement,
			cause = p.cause,
			jumping = p.jumping == true,
			killerId = p.killerId,
		})
	end
	return {
		tick = self.tick,
		time = self.time,
		phase = self.phase,
		winnerId = self.winnerId,
		reason = self.reason,
		players = players,
		segmentCount = #self.index.segments,
	}
end
return Sim
