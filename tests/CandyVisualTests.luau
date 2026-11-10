--!strict
return function()
	local S = game:GetService("ReplicatedStorage").TrailWars
	local Layout = require(S.CandyLayout)
	local Replay = require(S.CandyReplay)
	local n = 0
	local function check(v, message)
		assert(v, message)
		n += 1
	end
	for _, size in
		{
			{ 1672, 941 },
			{ 390, 844 },
			{ 320, 568 },
			{ 749, 381 },
			{ 749, 311 },
			{ 320, 498 },
			{ 2560, 1080 },
			{ 3440, 1440 },
			{ 768, 1024 },
			{ 1024, 768 },
		}
	do
		local w, h = size[1], size[2]
		local l = Layout.compute(w, h)
		check(math.abs(l.field[3] / l.field[4] - 1300 / 800) < 1e-8, "World aspect retained")
		for _, key in { "field", "left", "right", "homing", "jump", "home" } do
			local r = l[key]
			check(r[1] >= 0 and r[2] >= 0 and r[1] + r[3] <= w + 0.01 and r[2] + r[4] <= h + 0.01, "Visible " .. key)
		end
		for _, key in { "left", "right", "homing", "jump", "home" } do
			check(l[key][3] >= 44 and l[key][4] >= 44, "Touch target " .. key)
			local a, b = l.field, l[key]
			check(
				a[1] + a[3] <= b[1] or b[1] + b[3] <= a[1] or a[2] + a[4] <= b[2] or b[2] + b[4] <= a[2],
				"Controls clear of arena"
			)
		end
	end
	local r = Replay.new()
	local jumped, homing, turret, crash = false, false, false, false
	for _ = 1, 600 do
		r:step()
		local s = r:snapshot()
		for _, p in s.players do
			if p.id == "comet" and p.jumping then
				jumped = true
			end
		end
		for _, q in s.powers.projectiles do
			if q.kind == "Homing" then
				homing = true
			elseif q.kind == "Turret" then
				turret = true
			end
		end
		for _, e in r.events do
			if e.kind == "Eliminated" then
				crash = true
			end
		end
	end
	check(r.activations.Jump and jumped, "Real Jump activation in review")
	check(r.activations.Homing and homing, "Real Homing in review")
	check(turret and crash, "Real collision and post-death rocket in review")
	print(
		string.format(
			"CANDY VISUAL CONTRACT: %d assertions; deterministic real-engine fixture and presentation bounds",
			n
		)
	)
	return { passed = n, failed = 0 }
end
