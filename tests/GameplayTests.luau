--!strict
return function()
	local shared = game:GetService("ReplicatedStorage").TrailWars
	local G = require(shared.Geometry)
	local Sim = require(shared.Simulation)
	local Index = require(shared.TrailIndex)
	local Bot = require(shared.BotController)
	local Stepper = require(shared.FixedStepper)
	local checks = 0
	local function check(value: boolean, message: string)
		assert(value, message)
		checks += 1
	end
	local function near(a: number?, b: number, tol: number?)
		return a ~= nil and math.abs(a - b) < (tol or 1e-6)
	end
	check(near(G.capsuleTOI(0, 0, 100, 0, 50, -10, 50, 10, 2), 0.48), "Fast swept trail crossing")
	check(near(G.capsuleTOI(0, 2, 100, 2, 50, 0, 50, 0, 2), 0.5), "Tangent degenerate capsule contact")
	check(G.capsuleTOI(0, 2.01, 100, 2.01, 50, 0, 50, 0, 2) == nil, "Near tangent clear")
	check(near(G.wallTOI(10, 10, 200, 10, 100, 100, 2), 88 / 190), "Continuous wall contact")
	check(near(G.circleTOI(-20, 0, 20, 0, 0, 0, 2), 0.45), "Relative head collision")
	check(
		G.growingTOI(5, -1, 5, 9, 0, 0, 10, 0, 0.05) == nil,
		"Future trail cannot kill a core that crosses before emission"
	)
	check(G.growingTOI(5, -9, 5, 1, 0, 0, 10, 0, 0.05) ~= nil, "Already emitted same-tick trail is lethal")
	local index = Index.new(10)
	index:insert({ ax = 9, ay = 0, bx = 11, by = 0, owner = "a" })
	check(#index:query(0, 0, 20, 0, 1) == 1, "Grid candidates deduplicated")
	check(#index:query(100, 100, 110, 110, 1) == 0, "Grid rejects distant candidates")
	local c = {
		Speed = 100,
		TurnRate = 2,
		Step = 0.02,
		RampSeconds = 0,
		Width = 100000,
		Height = 100000,
		MaxRoundSeconds = 10000,
	}
	local s =
		Sim.new({ { id = "a", x = 1000, y = 1000, heading = 0 }, { id = "b", x = 20000, y = 20000, heading = 0 } }, c)
	for _ = 1, 50 do
		Sim.step(s, { a = 0, b = 0 })
	end
	check(near(s.byId.a.x, 1100) and near(s.byId.a.y, 1000), "Straight 100 units per simulated second")
	local p = { x = 0, y = 0, heading = 0, distance = 0 }
	local turn = Sim.motion(p, 1, math.pi / 2, { Speed = 100, TurnRate = 2, RampSeconds = 0 }, 0)
	check(near(turn.x, 0) and near(turn.y, 100), "Analytic half-circle radius 50")
	local released = Sim.motion(turn, 0, 0.1, { Speed = 100, TurnRate = 2, RampSeconds = 0 }, 10)
	check(near(released.heading, turn.heading), "Release preserves heading")
	local loop =
		Sim.new({ { id = "a", x = 300, y = 300, heading = 0 }, { id = "b", x = 20000, y = 20000, heading = 0 } }, c)
	for _ = 1, 300 do
		if loop.phase ~= "Active" then
			break
		end
		Sim.step(loop, { a = 1, b = 0 })
	end
	check(not loop.byId.a.alive and loop.byId.a.cause == "SelfTrail", "Full circle self-collision")
	local pair = Sim.new(
		{ { id = "a", x = 100, y = 100, heading = 0 }, { id = "b", x = 130, y = 100, heading = math.pi } },
		{ Speed = 1000, TurnRate = 2, RampSeconds = 0, Step = 0.02 }
	)
	Sim.step(pair, { a = 0, b = 0 })
	check(not pair.byId.a.alive and not pair.byId.b.alive and pair.reason == "Draw", "Simultaneous head-on is a draw")
	local reversed = Sim.new(
		{ { id = "b", x = 130, y = 100, heading = math.pi }, { id = "a", x = 100, y = 100, heading = 0 } },
		{ Speed = 1000, TurnRate = 2, RampSeconds = 0, Step = 0.02 }
	)
	Sim.step(reversed, { a = 0, b = 0 })
	check(near(pair.byId.a.x, reversed.byId.a.x), "Player iteration order cannot change contact location")
	local crossed = Sim.new(
		{ { id = "a", x = 100, y = 100, heading = 0 }, { id = "b", x = 700, y = 500, heading = 0 } },
		{ Speed = 1000, RampSeconds = 0, Step = 0.02 }
	)
	crossed.index:insert({ owner = "b", ax = 110, ay = 80, bx = 110, by = 120, endDistance = 20 })
	Sim.step(crossed, { a = 0, b = 0 })
	check(not crossed.byId.a.alive and crossed.byId.a.cause == "Trail", "Opponent trail impact")
	local positions = {}
	for _, fps in { 30, 60, 144 } do
		local state = Sim.new(
			{ { id = "a", x = 1000, y = 1000, heading = 0 }, { id = "b", x = 20000, y = 20000, heading = 0 } },
			c
		)
		local acc = Stepper.new(0.02, 8, 0.5)
		for _ = 1, fps * 2 do
			acc:advance(1 / fps, function()
				Sim.step(state, { a = 0, b = 0 })
			end)
		end
		positions[fps] = state.byId.a.x
	end
	check(
		near(positions[30], positions[144]) and near(positions[60], positions[144]),
		"30/60/144fps fixed-step invariance"
	)
	local stalled = Stepper.new(0.02, 8, 0.5)
	local ran = 0
	stalled:advance(5, function()
		ran += 1
	end)
	check(
		ran == 8 and stalled.droppedSeconds > 4,
		"Large frame backlog bounded without skipping simulated collision steps"
	)
	local started = os.clock()
	local rounds, segments = 0, 0
	for seed = 1, 20 do
		local roster = {}
		for i = 1, 6 do
			table.insert(roster, {
				id = tostring(i),
				name = "BOT" .. i,
				isBot = true,
				heading = 2 * math.pi * (i - 1) / 6 + math.pi + (seed - 10) * 0.017,
			})
		end
		local state = Sim.new(roster, { MaxRoundSeconds = 20 })
		while state.phase == "Active" do
			local inputs = {}
			for _, a in state.players do
				if a.alive then
					inputs[a.id] = Bot.input(state, a)
				end
			end
			Sim.step(state, inputs)
		end
		rounds += 1
		segments = math.max(segments, #state.index.segments)
	end
	check(rounds == 20 and segments <= 20000, "Six-bot bounded round soak")
	print(
		string.format(
			"GAMEPLAY: %d assertions, %d six-bot rounds, peak %d segments, %.3fs CPU elapsed",
			checks,
			rounds,
			segments,
			os.clock() - started
		)
	)
	return { passed = checks, failed = 0 }
end
