--!strict
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("TrailWars")
local Config = require(Shared.Config)
local Schema = require(Shared.ProfileSchema)
local ProfileStore = {}
ProfileStore.__index = ProfileStore

-- Injected store and clock make failure/retry/session behavior testable in Studio.
function ProfileStore.new(store: any, clock: (() -> number)?, owner: string?)
	return setmetatable({ store = store, clock = clock or os.time,
		owner = owner or (game.JobId .. ":" .. HttpService:GenerateGUID(false)),
		cache = {}, busy = {}, closing = {}, stopped = false }, ProfileStore)
end
function ProfileStore:_serial(userId: number, operation: () -> (boolean, string)): (boolean, string)
	local deadline = os.clock() + 15
	while self.busy[userId] do
		if os.clock() >= deadline then return false, "BUSY" end
		task.wait(0.05)
	end
	self.busy[userId] = true
	local ok, success, code = pcall(operation)
	self.busy[userId] = nil
	if not ok then return false, "DATA_UNAVAILABLE" end
	return success, code
end
function ProfileStore:load(userId: number): (boolean, string)
	return self:_serial(userId, function()
		if self.stopped or self.closing[userId] then return false, "CLOSING" end
		local reason = "DATA_UNAVAILABLE"
		local result = self.store:UpdateAsync("u_" .. userId, function(raw: any)
			-- UpdateAsync may rerun this pure callback. Do not grant effects here.
			local profile, problem = Schema.migrate(raw)
			if not profile then reason = problem or reason; return nil end
			local now = self.clock()
			if profile.lease and profile.lease.owner ~= self.owner and profile.lease.expires > now then
				reason = "SESSION_LOCKED"; return nil
			end
			profile.lease = { owner = self.owner, expires = now + Config.LeaseSeconds }
			reason = "OK"
			return profile
		end)
		if result == nil or reason ~= "OK" then return false, reason end
		self.cache[userId] = result
		return true, "OK"
	end)
end
function ProfileStore:transact(userId: number, change: (any) -> (boolean, string)): (boolean, string)
	return self:_serial(userId, function()
		if self.stopped or self.closing[userId] then return false, "CLOSING" end
		if not self.cache[userId] then return false, "PROFILE_UNAVAILABLE" end
		local reason = "DATA_UNAVAILABLE"
		local result = self.store:UpdateAsync("u_" .. userId, function(raw: any)
			local profile, problem = Schema.migrate(raw)
			if not profile then reason = problem or reason; return nil end
			local now = self.clock()
			if not profile.lease or profile.lease.owner ~= self.owner or profile.lease.expires <= now then
				reason = "SESSION_LOST"; return nil
			end
			local accepted, status = change(profile)
			reason = status
			if not accepted then return nil end
			profile.revision += 1
			profile.lease.expires = now + Config.LeaseSeconds
			return profile
		end)
		if result == nil then
			if reason == "SESSION_LOST" then self.cache[userId] = nil end
			return false, reason
		end
		self.cache[userId] = result
		return true, reason
	end)
end
function ProfileStore:snapshot(userId: number): any?
	if self.busy[userId] then return nil end
	local profile = self.cache[userId]
	if not profile or not profile.lease or profile.lease.expires <= self.clock() then return nil end
	return Schema.public(profile)
end
function ProfileStore:isBusy(userId: number): boolean
	return self.busy[userId] == true
end
function ProfileStore:heartbeat(userId: number): (boolean, string)
	return self:transact(userId, function(_profile: any) return true, "OK" end)
end
function ProfileStore:release(userId: number): (boolean, string)
	self.closing[userId] = true
	local success, code = self:_serial(userId, function()
		local result = self.store:UpdateAsync("u_" .. userId, function(raw: any)
			if type(raw) ~= "table" or not raw.lease or raw.lease.owner ~= self.owner then return nil end
			local profile = Schema.copy(raw)
			profile.lease = nil
			return profile
		end)
		return result ~= nil, if result then "OK" else "SESSION_LOST"
	end)
	self.cache[userId] = nil
	self.closing[userId] = nil
	-- Failed release expires naturally; never clear somebody else's lock.
	return success, code
end
return ProfileStore
