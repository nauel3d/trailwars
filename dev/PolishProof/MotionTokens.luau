--!strict
local tokens = {
	press = { time = 0.045, ease = "Quad" },
	release = { time = 0.12, ease = "Back" },
	select = { time = 0.10, ease = "Quad" },
	enter = { time = 0.18, ease = "Quad" },
	exit = { time = 0.10, ease = "Quad" },
	reorder = { time = 0.30, ease = "Cubic" },
	settle = { time = 0.16, ease = "Back" },
	confirm = { time = 0.22, ease = "Quad" },
	celebrate = { time = 0.46, ease = "Quad" },
	warning = { time = 0.14, ease = "Quad" },
}
for name, spec in require(game:GetService("ReplicatedStorage").TrailWars.GameplayMotion).Tweens do
	tokens[name] = spec
end
return tokens
