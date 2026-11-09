--!strict
-- Isolated proof, no App production bootstrap, backend or commerce.
local RS = game:GetService("ReplicatedStorage")
local Shell = require(RS:WaitForChild("TrailWarsDev"):WaitForChild("PolishProof").Shell)
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
Shell.mount(playerGui)
-- The isolated menu proof has no character controls or gameplay.
local playerModule = player.PlayerScripts:WaitForChild("PlayerModule")
require(playerModule):GetControls():Disable()
