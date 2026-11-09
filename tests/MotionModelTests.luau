--!strict
local Demo = require("../dev/PolishProof/DemoModel")
local Rank = require("../dev/PolishProof/RankModel")
local model = Demo.new()
local peak = 0
for _ = 1, 3600 do
	Demo.step(model, 1 / 30)
	for _, a in model.agents do
		peak = math.max(peak, #a.trail)
		assert(#a.trail <= 47, "Trail history must remain bounded")
		assert(a.x > -0.1 and a.x < 1.1 and a.y > -0.1 and a.y < 1.1, "Demo must remain within arena envelope")
		assert(a.x == a.x and a.y == a.y, "Simulation coordinates must be finite")
	end
end
assert(model.turns > 0, "Cores must turn to avoid hazards")
assert(model.crashes > 0, "Demonstration must include a crash")
local again = Demo.new()
for _ = 1, 3600 do
	Demo.step(again, 1 / 30)
end
assert(model.crashes == again.crashes and model.agents[1].x == again.agents[1].x, "Demo should be deterministic")
local data = {
	{ id = "b", name = "B", score = 10 },
	{ id = "a", name = "A", score = 10 },
	{
		id = "c",
		name = "C",
		score = 100,
		eliminated = true,
	},
}
local ordered = Rank.order(data)
assert(
	ordered[1].id == "a" and ordered[2].id == "b" and ordered[3].id == "c",
	"Live rows before eliminated; deterministic ties"
)
assert(data[1].id == "b", "Ranking must not mutate event data")
local final = Rank.order({
	{ id = "a", name = "A", score = 100, finalRank = 2 },
	{ id = "b", name = "B", score = 1, finalRank = 1 },
})
assert(final[1].id == "b", "Explicit final placement beats preview scores")
assert(not pcall(function()
	Rank.order({ { id = "a", name = "A", score = 1 }, { id = "a", name = "A again", score = 2 } })
end), "Duplicate identities rejected")
assert(not pcall(function()
	Rank.order({ { id = "a", name = "A", score = 0 / 0 } })
end), "NaN score rejected")
print(
	string.format(
		"MOTION MODELS: 120 seconds, %d crashes, %d turns, peak %d trail points; deterministic ranking/final placement/validation passed. Decoration only.",
		model.crashes,
		model.turns,
		peak
	)
)
