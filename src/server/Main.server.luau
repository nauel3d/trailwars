--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("TrailWars")
local Config = require(Shared.Config)
local Contracts = require(Shared.Contracts)
local ProfileStore = require(script.Parent.ProfileStore)
local Economy = require(script.Parent.EconomyService)
local MockStore = require(script.Parent.MockStore)
local PurchaseService = require(script.Parent.PurchaseService)

Players.CharacterAutoLoads = false
local isMock = RunService:IsStudio() and Config.EnableStudioMock
local enabled = isMock or Config.EnableProductionProfiles
local store = if isMock then MockStore.new() elseif enabled then DataStoreService:GetDataStore(Config.DataStoreName) else MockStore.new()
local profiles = ProfileStore.new(store)
local request = Instance.new("RemoteFunction")
request.Name = Contracts.RemoteName
request.Parent = Shared
local matchEvent = Instance.new("RemoteEvent")
matchEvent.Name = Contracts.MatchEventName
matchEvent.Parent = Shared
local nextRequest: { [number]: number } = {}
local loading: { [number]: boolean } = {}
local shuttingDown = false

local function response(player: Player, ok: boolean, code: string): any
	return { ok = ok, code = code, profile = profiles:snapshot(player.UserId), isMock = isMock }
end
local function joined(player: Player)
	if not enabled or shuttingDown then return end
	loading[player.UserId] = true
	local loaded = false
	for attempt = 1, 3 do
		if player.Parent ~= Players or shuttingDown then break end
		loaded = profiles:load(player.UserId)
		if loaded then break end
		task.wait(attempt)
	end
	loading[player.UserId] = nil
	if loaded and (player.Parent ~= Players or shuttingDown) then profiles:release(player.UserId) end
end
Players.PlayerAdded:Connect(joined)
for _, player in Players:GetPlayers() do task.spawn(joined, player) end
Players.PlayerRemoving:Connect(function(player: Player)
	nextRequest[player.UserId] = nil
	if enabled then profiles:release(player.UserId) end
end)

request.OnServerInvoke = function(player: Player, message: any): any
	if shuttingDown then return response(player, false, "CLOSING") end
	if not enabled then return response(player, false, "PRODUCTION_NOT_CONFIGURED") end
	local now = os.clock()
	if now < (nextRequest[player.UserId] or 0) then return response(player, false, "RATE_LIMITED") end
	nextRequest[player.UserId] = now + Config.RemoteCooldownSeconds
	if type(message) ~= "table" or type(message.action) ~= "string" or not Contracts.Actions[message.action] then
		return response(player, false, "INVALID_REQUEST")
	end
	if loading[player.UserId] then return response(player, false, "LOADING") end
	if message.action == "Snapshot" then
		-- A reconciliation snapshot cannot confirm stale cache during a pending
		-- durable write. Return BUSY and let the client retain its unknown state.
		if profiles:isBusy(player.UserId) then return response(player, false, "BUSY") end
		if not profiles:snapshot(player.UserId) then
			loading[player.UserId] = true
			local recovered, code = profiles:load(player.UserId)
			loading[player.UserId] = nil
			if not recovered then return response(player, false, code) end
			if player.Parent ~= Players or shuttingDown then
				profiles:release(player.UserId)
				return response(player, false, "CLOSING")
			end
		end
		return response(player, true, "OK")
	end
	local success, code = profiles:transact(player.UserId, function(profile: any)
		if message.action == "Equip" then return Economy.equip(profile, message.itemId) end
		if message.action == "BuyEarned" then return Economy.buyEarned(profile, message.itemId) end
		if message.action == "SetSetting" then return Economy.setting(profile, message.setting, message.value) end
		return false, "INVALID_REQUEST"
	end)
	return response(player, success, code)
end
PurchaseService.bind(profiles, isMock or not enabled)
task.spawn(function()
	while not shuttingDown do
		task.wait(Config.HeartbeatSeconds)
		for _, player in Players:GetPlayers() do
			if profiles:snapshot(player.UserId) then task.spawn(function() profiles:heartbeat(player.UserId) end) end
		end
	end
end)
game:BindToClose(function()
	shuttingDown = true
	local outstanding = 0
	for _, player in Players:GetPlayers() do
		outstanding += 1
		task.spawn(function()
			profiles:release(player.UserId)
			outstanding -= 1
		end)
	end
	local deadline = os.clock() + 25
	while outstanding > 0 and os.clock() < deadline do task.wait(0.05) end
	profiles.stopped = true
end)
