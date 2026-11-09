--!strict
-- Original independent mathematical fixtures; no reference implementation code.
return function()
	local shared = game:GetService("ReplicatedStorage").TrailWars
	local G = require(shared.Geometry)
	local Sim = require(shared.Simulation)
	local Index = require(shared.TrailIndex)
	local checks = 0
	local started = os.clock()
	local function check(value: boolean, message: string)
		assert(value, message)
		checks += 1
	end
	local function near(a: number?, b: number, tolerance: number?)
		return a ~= nil and math.abs(a - b) <= (tolerance or 1e-6)
	end
	local config = {
		Step = 1,
		Speed = 40,
		RampSeconds = 0,
		CoreRadius = 1,
		TrailRadius = 1,
		Width = 1000,
		Height = 1000,
		SelfGraceDistance = 5,
		CellSize = 10,
	}
	local function chronological(crossX: number, reverse: boolean)
		local roster = {
			{ id = "a", x = 10, y = 100, heading = 0 },
			{ id = "b", x = crossX, y = 130, heading = -math.pi / 2 },
			{ id = "c", x = 800, y = 800, heading = 0 },
		}
		if reverse then
			roster[1], roster[3] = roster[3], roster[1]
		end
		local state = Sim.new(roster, config)
		state.index:insert({ owner = "c", ax = 30, ay = 95, bx = 30, by = 105, endDistance = 10 })
		Sim.step(state, {})
		return state
	end
	local future = chronological(40, false)
	check(not future.byId.a.alive and near(future.byId.a.x, 28), "Earlier fatal hit truncates emitted path")
	check(future.byId.b.alive and near(future.byId.b.y, 90), "A future path beyond dead emitter cannot kill")
	local past = chronological(20, false)
	check(not past.byId.b.alive and near(past.byId.b.y, 102), "Already emitted dead trail remains lethal later in tick")
	check(
		#past.events == 2 and past.events[1].id == "a" and past.events[2].id == "b",
		"Same-tick deaths resolve chronologically"
	)
	check(
		past.byId.a.placement == 3 and past.byId.b.placement == 2,
		"Chronological placements count survivors at each event"
	)
	for _, x in { 20, 40 } do
		local normal, reverse = chronological(x, false), chronological(x, true)
		for _, id in { "a", "b", "c" } do
			local a, b = normal.byId[id], reverse.byId[id]
			check(
				a.alive == b.alive and a.cause == b.cause and near(a.x, b.x) and near(a.y, b.y),
				"Explicit-spawn outcome independent of player order"
			)
		end
	end
	local tied = Sim.new({
		{ id = "a", x = 80, y = 50, heading = 0 },
		{ id = "b", x = 30, y = 300, heading = 0 },
		{ id = "c", x = 30, y = 600, heading = 0 },
	}, { Step = 1, Speed = 40, RampSeconds = 0, Width = 100, Height = 1000, CoreRadius = 1, TrailRadius = 1 })
	tied.index:insert({ owner = "b", ax = 101, ay = 40, bx = 101, by = 60, endDistance = 20 })
	Sim.step(tied, {})
	check(not tied.byId.a.alive and near(tied.byId.a.x, 99), "Coincident wall and trail stop at common first contact")
	check(
		#tied.events == 1 and tied.byId.a.cause == "Wall",
		"Coincident causes emit one elimination with wall precedence"
	)

	-- A shallow arc can leave the arena even though both endpoints stay inside.
	-- The conservative envelope must include this production-50Hz sagitta.
	local arcWall = Sim.new({
		{ id = "a", x = 998.99, y = 100, heading = math.pi / 2 - 0.026 },
		{ id = "b", x = 100, y = 500, heading = 0 },
	}, {
		Width = 1000,
		Height = 1000,
		CoreRadius = 1,
		TrailRadius = 1,
		Speed = 105,
		TurnRate = 2.6,
		Step = 0.02,
		RampSeconds = 0,
	})
	local arcMid = Sim.motion(arcWall.byId.a, 1, 0.01, arcWall.config, 0)
	check(arcMid.x > 999, "Arc-wall fixture actually leaves legal arena at midpoint")
	Sim.step(arcWall, { a = 1, b = 0 })
	check(
		not arcWall.byId.a.alive and arcWall.byId.a.cause == "Wall",
		"Conservative sweep catches midpoint arc-wall graze"
	)
	check(arcWall.byId.a.x <= 999 + 1e-6, "Arc-wall graze never commits beyond safe wall")

	-- A chord TOI cannot be committed as a fresh fractional arc. A strong-turn
	-- fixture makes the different positions large enough to catch unambiguously.
	local fractional = Sim.new({
		{ id = "a", x = 90, y = 100, heading = 0 },
		{ id = "b", x = 20, y = 500, heading = 0 },
	}, {
		Width = 100,
		Height = 1000,
		CoreRadius = 1,
		TrailRadius = 1,
		Speed = 40,
		TurnRate = math.pi / 2,
		Step = 1,
		RampSeconds = 0,
	})
	Sim.step(fractional, { a = 1, b = 0 })
	check(not fractional.byId.a.alive and fractional.byId.a.cause == "Wall", "Fractional curved wall impact eliminates")
	check(fractional.byId.a.x <= 99 + 1e-6, "Fractional chord impact does not commit the deeper arc position")

	-- Broad phase must include every mathematically intersecting segment, including
	-- negative coordinates and exact cell edges, while returning each at most once.
	local grid = Index.new(10)
	for _, data in
		{
			{ -10, -20, -10, 20 },
			{ 0, 0, 30, 0 },
			{ 10, 10, 10, 10 },
			{ -0.001, -10, 0.001, 10 },
			{ 20, -20, 20, 20 },
		}
	do
		grid:insert({ ax = data[1], ay = data[2], bx = data[3], by = data[4], owner = "fixture" })
	end
	for _, ray in
		{
			{ -30, 0, 30, 0, 0 },
			{ -11, -30, -11, 30, 1 },
			{ 9, 9, 11, 11, 0 },
			{ 30, 1, 30, 1, 1 },
			{ -30, -30, 30, 30, 2 },
		}
	do
		local found = {}
		for _, segment in grid:query(ray[1], ray[2], ray[3], ray[4], ray[5]) do
			check(not found[segment.id], "Grid deduplicates segments spanning cells")
			found[segment.id] = true
		end
		for _, segment in grid.segments do
			local t =
				G.capsuleTOI(ray[1], ray[2], ray[3], ray[4], segment.ax, segment.ay, segment.bx, segment.by, ray[5])
			check(t == nil or found[segment.id] == true, "Grid retains every exact-boundary narrow-phase collision")
		end
	end

	local function grace(distance: number, endDistance: number, owner: string)
		local state = Sim.new({
			{ id = "a", x = 100, y = 100, heading = 0 },
			{ id = "b", x = 800, y = 800, heading = 0 },
		}, config)
		state.byId.a.distance = distance
		state.index:insert({ owner = owner, ax = 110, ay = 95, bx = 110, by = 105, endDistance = endDistance })
		Sim.step(state, {})
		return state.byId.a
	end
	check(grace(10, 5, "a").alive, "Own tail at exact grace-distance boundary is exempt for step")
	check(not grace(10.001, 5, "a").alive, "Own older trail outside grace distance is lethal")
	check(not grace(10, 10, "b").alive, "Opponent tail receives no self grace")

	check(near(G.pointSegmentSq(3, 4, 0, 0, 0, 0), 25), "Zero-length segment has point distance")
	check(G.circleTOI(5, 0, 5, 0, 0, 0, 1) == nil, "Stationary disjoint circle has no impact")
	check(near(G.circleTOI(1, 0, 1, 0, 0, 0, 1), 0), "Stationary tangent begins in contact")
	check(near(G.growingTOI(-5, 0, 5, 0, 0, 0, 0, 0, 1), 0.4), "Zero-length growing trail reduces to stationary point")
	check(G.capsuleTOI(5, 5, 5, 5, 0, 0, 0, 0, 1) == nil, "Stationary degenerate capsule remains disjoint")
	check(near(G.wallTOI(-1, 5, -1, 5, 10, 10, 1), 0), "Invalid outside-arena start resolves immediately")
	check(near(G.wallTOI(1, 5, 0, 5, 10, 10, 1), 0), "Boundary start moving outward resolves immediately")
	check(G.wallTOI(1, 5, 2, 5, 10, 10, 1) == nil, "Boundary start moving inward remains clear")
	local nan = 0 / 0
	check(G.circleTOI(nan, 0, 1, 0, 0, 0, 1) == nil, "Nonfinite circle candidate cannot become accepted TOI")
	check(G.growingTOI(nan, 0, 1, 0, 0, 0, 1, 0, 1) == nil, "Nonfinite growing candidate cannot become accepted TOI")

	-- Independent oracle: evaluate point-to-currently-emitted-segment distance on
	-- a dense time lattice. Cases are deterministic and exclude no random misses.
	local seed = 71823
	local function random()
		seed = (seed * 48271) % 2147483647
		return seed / 2147483647
	end
	for case = 1, 120 do
		local ax, ay, bx, by = random() * 20 - 10, random() * 20 - 10, random() * 20 - 10, random() * 20 - 10
		local cx, cy, dx, dy = random() * 20 - 10, random() * 20 - 10, random() * 20 - 10, random() * 20 - 10
		local r = 0.2 + random() * 2
		local function distanceAt(t: number)
			local px, py = ax + (bx - ax) * t, ay + (by - ay) * t
			local ex, ey = cx + (dx - cx) * t, cy + (dy - cy) * t
			local vx, vy = ex - cx, ey - cy
			local lengthSq = vx * vx + vy * vy
			local fraction = if lengthSq == 0 then 0 else math.clamp(((px - cx) * vx + (py - cy) * vy) / lengthSq, 0, 1)
			return math.sqrt((px - cx - fraction * vx) ^ 2 + (py - cy - fraction * vy) ^ 2)
		end
		local analytic = G.growingTOI(ax, ay, bx, by, cx, cy, dx, dy, r)
		local sampled: number? = nil
		for step = 0, 4096 do
			if distanceAt(step / 4096) <= r then
				sampled = step / 4096
				break
			end
		end
		check(
			not sampled or (analytic ~= nil and analytic <= sampled + 1e-6),
			"Growing sweep cannot miss dense observed contact case " .. case
		)
		if analytic then
			check(
				analytic >= 0 and analytic <= 1 and distanceAt(analytic) <= r + 1e-6,
				"Growing sweep returns a real contact case " .. case
			)
			check(
				sampled == nil or near(analytic, sampled, 1 / 4096 + 1e-6),
				"Growing sweep agrees with earliest dense sample case " .. case
			)
		end
	end
	print(string.format("GAMEPLAY EDGES: %d assertions, %.3fs CPU", checks, os.clock() - started))
	return { passed = checks, failed = 0 }
end
