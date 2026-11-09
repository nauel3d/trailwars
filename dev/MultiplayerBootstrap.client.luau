--!strict
local RS = game:GetService("ReplicatedStorage")
local transport = require(RS.TrailWarsUI.GameplayTransport).new()
local proof = require(RS.TrailWarsUI.GameplayApp).mount(
	game.Players.LocalPlayer:WaitForChild("PlayerGui"),
	RS.TrailWarsDev,
	transport
)
local pm = game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")
require(pm):GetControls():Disable()
if game:GetService("RunService"):IsStudio() then
	local probe = Instance.new("BindableFunction")
	probe.Name = "GameplayProbe"
	probe.Parent = proof.gui
	probe.OnInvoke = function(action, value)
		if action == "Start" then
			proof.start()
		elseif action == "Steer" then
			proof.steer(value)
		elseif action == "Resync" then
			transport:send("Resync")
		elseif action == "Home" then
			proof.home()
		end
		return proof.snapshot()
	end
end
