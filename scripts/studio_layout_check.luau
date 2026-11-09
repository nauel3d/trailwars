-- Execute once in the clean preview place's CLIENT during bundled verification.
-- Frame-sized engine layout simulation, not physical-device evidence.
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local App = require(RS.TrailWarsUI.App)
local Fixtures = require(RS.TrailWarsDev.Fixtures)
local gui = Instance.new("ScreenGui")
gui.Name = "TrailWarsLayoutCheck"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = Players.LocalPlayer.PlayerGui
local cases = {
	{ "Home", "Home" },
	{ "Customize", "Customize" },
	{ "Shop", "Shop" },
	{ "Settings", "Settings" },
	{ "Profile", "Profile" },
	{ "Tutorial", "Tutorial" },
	{ "Queue", "Demo", "Queue" },
	{ "HUD", "Demo", "HUD" },
	{ "Spectator", "Demo", "Spectator" },
	{ "Results", "Demo", "Results" },
	{ "Locked", "Customize", nil, "core_ring" },
	{ "Confirm", "Shop", nil, "trail_dashed", true },
}
local sizes = { { "desktop", 1365, 768 }, { "tablet", 768, 1024 }, { "phone", 390, 844 }, { "smallPhone", 320, 568 } }
local results = { cases = 0, failures = {}, scope = "Engine Frame-sized layout simulation; no physical devices" }
for _, size in sizes do
	for _, scale in { 1, 1.5 } do
		for _, case in cases do
			local target = Instance.new("Frame")
			target.Size = UDim2.fromOffset(size[2], size[3])
			target.Parent = gui
			local profile = Fixtures.profile(if case[1] == "Locked" then 0 else 480)
			profile.settings.textScale = scale
			local cleanup = App.mount(
				target,
				{
					preview = true,
					profile = profile,
					transport = Fixtures.transport(profile),
					initialRoute = case[2],
					initialPhase = case[3],
					initialItem = case[4],
					confirmPurchase = case[5],
				}
			)
			task.wait()
			task.wait()
			results.cases += 1
			for _, item in target:GetDescendants() do
				if
					(item:IsA("TextLabel") or item:IsA("TextButton"))
					and item.Visible
					and item.Text ~= ""
					and not item.TextFits
				then
					table.insert(
						results.failures,
						{
							device = size[1],
							scale = scale,
							route = case[1],
							name = item.Name,
							text = item.Text,
							width = item.AbsoluteSize.X,
							height = item.AbsoluteSize.Y,
						}
					)
				end
			end
			cleanup()
			target:Destroy()
		end
	end
end
gui:Destroy()
return results
