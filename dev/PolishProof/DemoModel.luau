--!strict
-- Pure deterministic decoration. No game services, remotes, real stats or rewards.
local Demo = {}
local function distance(ax: number, ay: number, bx: number, by: number): number
	return math.sqrt((ax - bx) ^ 2 + (ay - by) ^ 2)
end
function Demo.new()
	local self: any = {
		time = 0,
		crashes = 0,
		turns = 0,
		steps = 0,
		obstacles = {
			{ x = 0.48, y = 0.40, r = 0.07 },
			{ x = 0.66, y = 0.72, r = 0.055 },
		},
		agents = {},
	}
	for i, p in { { 0.15, 0.25, 0.2 }, { 0.80, 0.18, 2 }, { 0.32, 0.82, -0.7 } } do
		table.insert(self.agents, {
			id = ({ "blue", "coral", "gold" })[i],
			name = ({ "BOLT", "YOU · DEMO", "SUNNY" })[i],
			x = p[1],
			y = p[2],
			heading = p[3],
			trail = { { x = p[1], y = p[2] } },
			alive = true,
			restart = 0,
			score = 24 - i * 5,
			sample = 0,
			age = 0,
		})
	end
	return self
end
function Demo.clearance(self: any, x: number, y: number, agent: any): number
	local result = math.min(x - 0.035, 0.965 - x, y - 0.035, 0.965 - y)
	for _, o in self.obstacles do
		result = math.min(result, distance(x, y, o.x, o.y) - o.r - 0.018)
	end
	for _, other in self.agents do
		for j = 1, #other.trail - (if other == agent then 7 else 0), 3 do
			local p = other.trail[j]
			result = math.min(result, distance(x, y, p.x, p.y) - 0.016)
		end
	end
	return result
end
function Demo.step(self: any, dt: number)
	dt = math.clamp(dt, 0, 0.1)
	self.time += dt
	self.steps += 1
	for i, a in self.agents do
		if not a.alive then
			a.restart -= dt
			if a.restart <= 0 then
				a.x = 0.15 + (i - 1) * 0.3
				a.y = 0.15
				a.heading = 1.2 + i * 0.25
				a.trail = { { x = a.x, y = a.y } }
				a.alive = true
				a.age = 0
				a.score = 0
			end
		else
			a.age += dt
			a.score += dt * (2 + i * 0.25)
			local target = a.heading
			local risky = math.floor(self.time / 8) % 3 + 1 == i and self.time % 8 > 5.4
			if risky then
				target = math.atan2(self.obstacles[1].y - a.y, self.obstacles[1].x - a.x)
			elseif Demo.clearance(self, a.x + math.cos(target) * 0.10, a.y + math.sin(target) * 0.10, a) < 0.035 then
				local best = -math.huge
				for _, offset in { 0, 0.4, -0.4, 0.8, -0.8, 1.3, -1.3, 2, -2 } do
					local angle = a.heading + offset
					local score = Demo.clearance(self, a.x + math.cos(angle) * 0.11, a.y + math.sin(angle) * 0.11, a)
						- math.abs(offset) * 0.008
					if score > best then
						best = score
						target = angle
					end
				end
			end
			local delta = math.atan2(math.sin(target - a.heading), math.cos(target - a.heading))
			local change = math.clamp(delta, -2.8 * dt, 2.8 * dt)
			if math.abs(change) > 0.01 then
				self.turns += 1
			end
			a.heading += change
			local speed = 0.10 + i * 0.008
			a.x += math.cos(a.heading) * speed * dt
			a.y += math.sin(a.heading) * speed * dt
			a.sample += dt
			if a.sample >= 0.09 then
				a.sample = 0
				table.insert(a.trail, { x = a.x, y = a.y })
				if #a.trail > 47 then
					table.remove(a.trail, 1)
				end
			end
			if Demo.clearance(self, a.x, a.y, a) < -0.002 or (risky and a.age > 8 and self.time % 8 > 7.7) then
				a.alive = false
				a.restart = 1.25
				self.crashes += 1
			end
		end
	end
end
function Demo.rows(self: any)
	local rows = {}
	for _, a in self.agents do
		table.insert(rows, { id = a.id, name = a.name, score = math.floor(a.score), eliminated = not a.alive })
	end
	return rows
end
return Demo
