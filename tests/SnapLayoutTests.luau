--!strict
-- Official Luau CLI test of actual pure layout source, not a parallel model.
local Layout = require("../dev/PolishProof/Layout")
local cases = 0
local sizes = {
	{ 320, 568 },
	{ 360, 640 },
	{ 390, 844 },
	{ 568, 320 },
	{ 667, 375 },
	{ 844, 390 },
	{ 768, 1024 },
	{ 1024, 768 },
	{ 1280, 720 },
	{ 1672, 941 },
	{ 2560, 1080 },
}
for _, size in sizes do
	for _, scale in { 1, 1.25, 1.5 } do
		local l = Layout.home(size[1], size[2], scale)
		local actions = { l.play, table.unpack(l.nav) }
		assert(#actions == 5, "Home must expose Play and four destinations")
		for i, a in actions do
			assert(
				a[1] >= 0 and a[2] >= 0 and a[1] + a[3] <= size[1] + 1 and a[2] + a[4] <= size[2] + 1,
				"Action outside safe parent"
			)
			assert(a[3] >= 48 and a[4] >= 48, "Hit target under 48 logical pixels")
			for j = i + 1, #actions do
				local b = actions[j]
				local overlap = math.min(a[1] + a[3], b[1] + b[3]) > math.max(a[1], b[1])
					and math.min(a[2] + a[4], b[2] + b[4]) > math.max(a[2], b[2])
				assert(not overlap, "Home actions overlap")
			end
		end
		cases += 1
	end
end
print(
	string.format(
		"SNAP LAYOUT: %d viewport/text-scale cases; 5 visible actions, bounds, 48px targets and no action overlap. Static geometry, NOT engine text/input verification.",
		cases
	)
)
