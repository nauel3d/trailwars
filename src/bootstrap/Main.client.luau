--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local App = require(ReplicatedStorage:WaitForChild("TrailWarsUI"):WaitForChild("App"))
App.mount(Players.LocalPlayer:WaitForChild("PlayerGui"))
