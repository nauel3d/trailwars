--!strict
local RS = game:GetService("ReplicatedStorage")
local App = require(RS:WaitForChild("TrailWarsUI"):WaitForChild("App"))
local Fixtures = require(script.Parent.Parent.Fixtures)
return function(target: Frame)
	local profile = Fixtures.profile()
	profile.settings.textScale = 1.5
	local transport = Fixtures.transport(profile)
	return App.mount(target, { preview = true, profile = profile, initialRoute = "Settings", transport = transport })
end
