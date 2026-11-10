--!strict
-- Rendered-client measurements, kept separate from server/hidden-field CPU benchmarks.
return function(gui: ScreenGui, seconds: number?, snapshot: any?)
	local Run = game:GetService("RunService")
	local Stats = game:GetService("Stats")
	local duration = math.clamp(seconds or 10, 5, 20)
	local frames = {}
	local start = os.clock()
	local before = Stats:GetTotalMemoryUsageMb()
	local peakGui, peakInstances, peakPaths, peakEffects, peakRockets = 0, 0, 0, 0, 0
	local minLiving, maxLiving, peakSegments = 6, 0, 0
	local connection = Run.RenderStepped:Connect(function(dt)
		if os.clock() - start > 0.5 and #frames < 3600 then
			frames[#frames + 1] = dt * 1000
		end
	end)
	while os.clock() - start < duration + 0.5 do
		if snapshot then
			local state = snapshot()
			local alive = 0
			for _, p in state.players do
				if p.alive then
					alive += 1
				end
			end
			minLiving = math.min(minLiving, alive)
			maxLiving = math.max(maxLiving, alive)
			peakSegments = math.max(peakSegments, state.segmentCount)
		end
		local guis, paths, effects, rockets = 0, 0, 0, 0
		local objects = gui:GetDescendants()
		for _, x in objects do
			if x:IsA("GuiObject") then
				guis += 1
			end
			if x:IsA("Path2D") then
				paths += 1
			end
			if x:IsA("Frame") and x.Visible and x.Name:match("^Impact%d+$") then
				effects += 1
			end
			if x:IsA("Frame") and x.Visible and x.Name == "Rocket" then
				rockets += 1
			end
		end
		peakGui = math.max(peakGui, guis)
		peakInstances = math.max(peakInstances, #objects)
		peakPaths = math.max(peakPaths, paths)
		peakEffects = math.max(peakEffects, effects)
		peakRockets = math.max(peakRockets, rockets)
		task.wait(0.25)
	end
	connection:Disconnect()
	assert(#frames > 0, "No rendered client frames received")
	local sum = 0
	for _, ms in frames do
		sum += ms
	end
	table.sort(frames)
	local result: any = {
		method = "Visible native client RenderStepped intervals, excludes first0.5s; identical engine replay; Studio compositor/frame cap included",
		viewport = tostring(workspace.CurrentCamera.ViewportSize),
		frames = #frames,
		seconds = os.clock() - start,
		meanFrameMs = sum / #frames,
		p95FrameMs = frames[math.ceil(#frames * 0.95)],
		p99FrameMs = frames[math.ceil(#frames * 0.99)],
		maxFrameMs = frames[#frames],
		clientMemoryBeforeMb = before,
		clientMemoryAfterMb = Stats:GetTotalMemoryUsageMb(),
		peakGuiObjects = peakGui,
		peakGuiDescendants = peakInstances,
		peakPath2D = peakPaths,
		peakActiveImpacts = peakEffects,
		peakActiveRockets = peakRockets,
		minLivingBots = minLiving,
		maxLivingBots = maxLiving,
		peakSegments = peakSegments,
	}
	-- These properties are optional across Studio versions; omit inaccessible indicators.
	for _, property in { "RenderCPUFrameTime", "RenderGPUFrameTime", "SceneDrawcallCount", "SceneTriangleCount" } do
		local ok, value = pcall(function()
			return Stats[property]
		end)
		if ok then
			result[property] = value
		end
	end
	return result
end
