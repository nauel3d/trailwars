--!strict
local D = require(script.Parent.PowerDefinitions)
local G = require(script.Parent.Geometry)
local Power = {}
Power.__index = Power
function Power.new(sim: any, roundId: string, enabledTurrets: boolean, hit: any)
	local self: any = setmetatable({
		sim = sim,
		roundId = roundId,
		tick = 0,
		projectiles = {},
		actors = {},
		serial = 0,
		hit = hit,
		turrets = enabledTurrets,
		closed = false,
		events = {},
	}, Power)
	for _, p in sim.players do
		self.actors[p.id] = {
			ready = { Homing = D.Homing.InitialTicks, Jump = D.Jump.InitialTicks },
			jumpUntil = 0,
			nextRocket = 0,
			wasAlive = true,
			turn = 0,
		}
	end
	return self
end
function Power:_spawn(p: any, kind: string)
	if #self.projectiles >= D.MaxProjectiles then
		return false, "LIMIT"
	end
	for _, q in self.projectiles do
		if kind == "Turret" and q.kind == kind and q.owner == p.id then
			return false, "ACTIVE"
		end
	end
	local def = D[kind]
	self.serial += 1
	local heading = p.heading
	if kind == "Turret" then
		local nearest = math.huge
		for _, target in self.sim.players do
			local dist = (target.x - p.x) ^ 2 + (target.y - p.y) ^ 2
			if target.alive and target.id ~= p.id and dist < nearest then
				nearest = dist
				heading = math.atan2(target.y - p.y, target.x - p.x)
			end
		end
	end
	table.insert(self.projectiles, {
		id = self.roundId .. ":p" .. self.serial,
		owner = p.id,
		kind = kind,
		x = math.clamp(p.x, 10, self.sim.config.Width - 10),
		y = math.clamp(p.y, 10, self.sim.config.Height - 10),
		heading = heading,
		expires = self.tick + def.LifeTicks,
	})
	return true, "FIRED"
end
function Power:activate(id: string, slot: string, roundId: string): (boolean, string)
	if self.closed or self.sim.phase ~= "Active" or roundId ~= self.roundId then
		return false, "ROUND"
	end
	local p = self.sim.byId[id]
	local a = self.actors[id]
	if not p or not p.alive then
		return false, "DEAD"
	end
	if slot ~= "Homing" and slot ~= "Jump" then
		return false, "SLOT"
	end
	if self.tick < a.ready[slot] then
		return false, "COOLDOWN"
	end
	if slot == "Jump" then
		a.jumpUntil = self.tick + D.Jump.DurationTicks
		p.jumping = true
	else
		local ok, code = self:_spawn(p, "Homing")
		if not ok then
			return false, code
		end
	end
	a.ready[slot] = self.tick + D[slot].CooldownTicks
	table.insert(self.events, { id = id, kind = "Activated", slot = slot, tick = self.tick })
	return true, "ACTIVATED"
end
function Power:before(inputs: any)
	if self.closed then
		return
	end
	self.tick += 1
	self.previous = {}
	for _, p in self.sim.players do
		self.previous[p.id] = { x = p.x, y = p.y }
	end
	for _, p in self.sim.players do
		local a = self.actors[p.id]
		a.turn = inputs[p.id] or 0
		p.jumping = p.alive and self.tick < a.jumpUntil
	end
end
function Power:after()
	if self.closed then
		return
	end
	if self.sim.phase ~= "Active" then
		self:close()
		return
	end
	local alive = 0
	for _, p in self.sim.players do
		if p.alive then
			alive += 1
		end
	end
	for _, p in self.sim.players do
		local a = self.actors[p.id]
		if a.wasAlive and not p.alive then
			a.jumpUntil = 0
			a.nextRocket = self.tick + D.Turret.InitialTicks
			p.jumping = false
		end
		a.wasAlive = p.alive
		if not p.alive and p.cause ~= "Left" and self.turrets and alive >= 2 and self.tick >= a.nextRocket then
			local ok = self:_spawn(p, "Turret")
			if ok then
				a.nextRocket = self.tick + D.Turret.IntervalTicks
			end
		end
	end
	local keep = {}
	local dt = self.sim.config.Step
	for _, q in self.projectiles do
		local def = D[q.kind]
		if self.tick >= q.expires or q.kind == "Homing" and not self.sim.byId[q.owner].alive then
			continue
		end
		local turn = 0
		if q.kind == "Turret" then
			turn = self.actors[q.owner].turn
		else
			local best = def.Range ^ 2
			local target = nil
			for _, p in self.sim.players do
				local dist = (p.x - q.x) ^ 2 + (p.y - q.y) ^ 2
				if p.alive and not p.jumping and p.id ~= q.owner and dist < best then
					best = dist
					target = p
				end
			end
			if target then
				local desired = math.atan2(target.y - q.y, target.x - q.x)
				local angle = math.atan2(math.sin(desired - q.heading), math.cos(desired - q.heading))
				turn = math.clamp(angle / (def.TurnRate * dt), -1, 1)
			end
		end
		q.heading += turn * def.TurnRate * dt
		local x = q.x + math.cos(q.heading) * def.Speed * dt
		local y = q.y + math.sin(q.heading) * def.Speed * dt
		local victim = nil
		local earliest = 2
		for _, p in self.sim.players do
			if p.alive and not p.jumping and p.id ~= q.owner then
				local old = self.previous[p.id] or p
				local t = G.circleTOI(
					q.x - old.x,
					q.y - old.y,
					x - p.x,
					y - p.y,
					0,
					0,
					def.Radius + self.sim.config.CoreRadius
				)
				if t and (t < earliest or (t == earliest and p.id < (victim or "~"))) then
					earliest = t
					victim = p.id
				end
			end
		end
		if victim then
			self.hit(q.id, q.owner, victim, def.Steal, q.kind)
		elseif
			self.tick < q.expires
			and x >= 0
			and y >= 0
			and x <= self.sim.config.Width
			and y <= self.sim.config.Height
		then
			q.x = x
			q.y = y
			table.insert(keep, q)
		end
	end
	self.projectiles = keep
end
function Power:close()
	self.closed = true
	self.projectiles = {}
	for id, a in self.actors do
		a.jumpUntil = 0
		self.sim.byId[id].jumping = false
	end
end
function Power:snapshot()
	local actors = {}
	local projectiles = {}
	for id, a in self.actors do
		local p = self.sim.byId[id]
		actors[id] = {
			Homing = math.max(0, a.ready.Homing - self.tick) / 50,
			Jump = math.max(0, a.ready.Jump - self.tick) / 50,
			jumping = p.jumping == true,
			state = if p.alive
				then "Alive"
				elseif self.turrets and p.cause ~= "Left" and not self.closed then "EliminatedTurret"
				else "Spectator",
			nextRocket = math.max(0, a.nextRocket - self.tick) / 50,
		}
	end
	for _, q in self.projectiles do
		table.insert(projectiles, table.clone(q))
	end
	return { actors = actors, projectiles = projectiles }
end
return Power
