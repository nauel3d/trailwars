--!strict
-- Ordered reliable geometry stream, independently testable from Roblox Remotes.
local Replica = {}
Replica.__index = Replica
function Replica.new()
	return setmetatable({ state = nil, matchId = nil, received = 0, pending = {}, reset = false }, Replica)
end
function Replica:clear()
	self.state = nil
	self.matchId = nil
	self.received = 0
	self.pending = {}
	self.reset = true
end
function Replica:accept(packet: any): (boolean, string)
	if type(packet) ~= "table" or type(packet.state) ~= "table" or type(packet.segments) ~= "table" then
		return false, "SHAPE"
	end
	local s = packet.state
	local same = self.matchId == s.matchId
	if same and self.state and s.revision < self.state.revision then
		return false, "STALE"
	end
	if not same and not packet.full then
		return false, "RESYNC"
	end
	local expected = if packet.full then 1 else self.received + 1
	if packet.from ~= expected then
		return false, "RESYNC"
	end
	if same and self.state and s.revision == self.state.revision and not packet.full and #packet.segments == 0 then
		return false, "STALE"
	end
	if packet.full then
		self.received = 0
		self.pending = {}
		self.reset = true
	end
	self.matchId = s.matchId
	for _, segment in packet.segments do
		table.insert(self.pending, segment)
		self.received += 1
	end
	self.state = s
	return true, "OK"
end
function Replica:drain()
	local delta = self.pending
	self.pending = {}
	return delta
end
return Replica
