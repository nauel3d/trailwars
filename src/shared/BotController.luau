--!strict
local Geometry = require(script.Parent.Geometry)
local Simulation = require(script.Parent.Simulation)
local Bot = {}
function Bot.input(sim: any, p: any): number
	local c = sim.config
	local horizon = 0.75
	local best = -math.huge
	local chosen = 0
	for _, turn in { 0, -1, 1 } do
		local probe = { x = p.x, y = p.y, heading = p.heading, distance = p.distance }
		local score = 0
		for _ = 1, 12 do
			local nextState = Simulation.motion(probe, turn, horizon / 12, c, sim.time)
			local collision = Geometry.wallTOI(
				probe.x,
				probe.y,
				nextState.x,
				nextState.y,
				c.Width,
				c.Height,
				c.CoreRadius + 3
			) ~= nil
			if not collision then
				for _, s in
					sim.index:query(probe.x, probe.y, nextState.x, nextState.y, c.CoreRadius + c.TrailRadius + 3)
				do
					if s.owner ~= p.id or p.distance - s.endDistance > c.SelfGraceDistance then
						if
							Geometry.capsuleTOI(
								probe.x,
								probe.y,
								nextState.x,
								nextState.y,
								s.ax,
								s.ay,
								s.bx,
								s.by,
								c.CoreRadius + c.TrailRadius + 3
							)
						then
							collision = true
							break
						end
					end
				end
			end
			if collision then
				break
			end
			score += 1
			probe = nextState
		end
		-- Stable per-ID bias avoids symmetric endless circles without randomness.
		local bias = if turn == 0 then 0.12 elseif turn == p.turn then 0.07 else 0
		if score + bias > best then
			best = score + bias
			chosen = turn
		end
	end
	return chosen
end
return Bot
