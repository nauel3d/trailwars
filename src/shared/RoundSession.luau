--!strict
-- Engine-independent round lifecycle; identical local/server rules.
local Sim = require(script.Parent.Simulation)
local Bot = require(script.Parent.BotController)
local Defaults = require(script.Parent.GameplayConfig)
local Round = {}
function Round.new(roster: any, config: any?, identity: string?)
	local self: any = {
		roster = roster,
		config = config or Defaults,
		matchId = identity or "practice",
		phase = "Countdown",
		clock = 0,
		sim = Sim.new(roster, config),
		inputs = {},
		revision = 0,
	}
	return self
end
function Round.step(self: any)
	self.clock += self.sim.config.Step
	if self.phase == "Countdown" then
		if self.clock >= self.sim.config.CountdownSeconds then
			self.phase = "Active"
			self.clock = 0
		end
	elseif self.phase == "Active" then
		local inputs = table.clone(self.inputs)
		for _, p in self.sim.players do
			if p.isBot and p.alive then
				inputs[p.id] = Bot.input(self.sim, p)
			end
		end
		Sim.step(self.sim, inputs)
		if self.sim.phase == "Results" then
			self.phase = "Results"
			self.clock = 0
		end
	end
	self.revision += 1
end
function Round.remove(self: any, id: string)
	local p = self.sim.byId[id]
	self.inputs[id] = nil
	if p and p.alive then
		p.placement = Sim.alive(self.sim)
		p.alive = false
		p.cause = "Left"
	end
end
function Round.snapshot(self: any)
	local state = Sim.snapshot(self.sim)
	state.matchId = self.matchId
	state.phase = self.phase
	state.remaining = math.max(0, math.ceil(self.sim.config.CountdownSeconds - self.clock))
	state.revision = self.revision
	return state
end
return Round
