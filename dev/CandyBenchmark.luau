--!strict
-- Native CPU comparison, excludes GPU work. Real six-bot round geometry, bounded batches.
return function(parent: Instance)
	local RS = game.ReplicatedStorage
	local Round = require(RS.TrailWars.RoundSession)
	local Config = require(RS.TrailWars.GameplayConfig)
	local Kit = require(RS.TrailWarsDev.Components)
	local captures, peak, duration = {}, 0, 0
	local config = table.clone(Config)
	config.CountdownSeconds, config.MaxRoundSeconds = 0, 60
	local roster = {}
	for i = 1, 6 do
		roster[i] = { id = "r" .. i, name = "RACER " .. i, isBot = true }
	end
	local r = Round.new(roster, config, "candy-benchmark")
	local cursor = 0
	for i = 1, 3001 do
		Round.step(r)
		if i % 5 == 0 then
			local segments = {}
			for j = cursor + 1, #r.sim.index.segments do
				segments[#segments + 1] = r.sim.index.segments[j]
			end
			cursor = #r.sim.index.segments
			captures[#captures + 1] = { players = Round.snapshot(r).players, segments = segments }
			peak = math.max(peak, cursor)
		end
		if i % 100 == 0 then
			task.wait()
		end
		if r.phase == "Results" then
			break
		end
	end
	duration = r.sim.time
	local result: any = {
		method = "Native Roblox renderer update CPU only; shared real six-bot geometry; no device GPU/FPS claim",
		seconds = duration,
		peakSegments = peak,
		samples = #captures,
	}
	for _, mode in { "GameplayRenderer", "CandyFullActive", "CandyCometRenderer" } do
		local field = Kit.frame(parent, "BenchmarkField")
		field.Size = UDim2.fromOffset(1000, 1000 * 800 / 1300)
		field.Visible = false
		local renderer = require(RS.TrailWarsUI[if mode == "CandyFullActive" then "CandyCometRenderer" else mode]).new(
			field,
			Kit,
			Config,
			{ selfId = "r1", accentPoints = if mode == "CandyFullActive" then 48 else 8 }
		)
		local samples = {}
		for i, capture in captures do
			local start = os.clock()
			renderer:roster(capture.players)
			renderer:append(capture.segments)
			renderer:draw(capture.players)
			if renderer.step then
				renderer:step(0.1)
			end
			samples[i] = (os.clock() - start) * 1000
			if i % 20 == 0 then
				task.wait()
			end
		end
		local sum = 0
		for _, ms in samples do
			sum += ms
		end
		table.sort(samples)
		result[mode] = {
			meanMs = sum / #samples,
			p95Ms = samples[math.max(1, math.ceil(#samples * 0.95))],
			maxMs = samples[#samples],
			paths = renderer.pathCount,
			descendants = #field:GetDescendants(),
		}
		if mode == "CandyCometRenderer" then
			local function visibleEffects()
				local count = 0
				for _, x in field:GetChildren() do
					if x.Name:match("^Impact") and x.Visible then
						count += 1
					end
				end
				return count
			end
			renderer:events("test", {})
			local event = { sequence = 1, kind = "Eliminated", victim = "r1", x = 100, y = 100, cause = "Trail" }
			renderer:events("test", { event })
			local first = visibleEffects()
			renderer:events("test", { event })
			local duplicate = visibleEffects()
			renderer:reset()
			renderer:events("test", { event })
			local resync = visibleEffects()
			renderer:events("test", { { sequence = 2, kind = "Homing", victim = "r1", x = 100, y = 100 } })
			local fresh = visibleEffects()
			renderer:step(1)
			result.effectLifecycle =
				{ first = first, duplicate = duplicate, resync = resync, fresh = fresh, expired = visibleEffects() }
			assert(
				first == 1 and duplicate == 1 and resync == 0 and fresh == 1 and visibleEffects() == 0,
				"Event effects must be once-only and cleaned"
			)
		end
		renderer:destroy()
		field:Destroy()
	end
	return result
end
