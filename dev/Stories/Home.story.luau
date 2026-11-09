--!strict
local RS = game:GetService("ReplicatedStorage")
local App = require(RS:WaitForChild("TrailWarsUI"):WaitForChild("App"))
local Fixtures = require(script.Parent.Parent.Fixtures)
return function(target: Frame)
	local profile = Fixtures.profile()
	local transport = Fixtures.transport(profile)
	return App.mount(target, { preview = true, profile = profile, initialRoute = "Home", transport = transport })
end
