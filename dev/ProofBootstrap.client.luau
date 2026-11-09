--!strict
-- Isolated appearance proof. No server grants or commerce configuration.
local RS = game:GetService("ReplicatedStorage")
local App = require(RS:WaitForChild("TrailWarsUI"):WaitForChild("App"))
local Fixtures = require(RS:WaitForChild("TrailWarsDev"):WaitForChild("Fixtures"))
local profile = Fixtures.profile(480)
App.mount(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"), {
	profile = profile,
	initialRoute = "Customize",
	transport = Fixtures.transport(profile),
})
