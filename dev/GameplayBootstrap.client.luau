--!strict
local RS = game:GetService("ReplicatedStorage")
local App = require(RS.TrailWarsUI.GameplayApp)
local proof = App.mount(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"), RS.TrailWarsDev)
-- Local-only Studio diagnostic hook, never a remote or production authority.
if game:GetService("RunService"):IsStudio() then
	local probe = Instance.new("BindableFunction")
	probe.Name = "GameplayProbe"
	probe.Parent = proof.gui
	probe.OnInvoke = function(action: string, value: any)
		if action == "Start" then
			proof.start()
		elseif action == "Steer" then
			proof.steer(value)
		elseif action == "Home" then
			proof.home()
		end
		return proof.snapshot()
	end
end
local pm = game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")
require(pm):GetControls():Disable()
