--!strict
local Config = require(script.Parent.GameplayConfig)
local Protocol = {}
function Protocol.validate(message: any): (boolean, string)
	if type(message) ~= "table" or getmetatable(message) ~= nil then
		return false, "SHAPE"
	end
	local count = 0
	for key in message do
		count += 1
		if key ~= "action" and key ~= "sequence" and key ~= "matchId" and key ~= "turn" then
			return false, "FIELD"
		end
	end
	if count > 4 then
		return false, "FIELDS"
	end
	if
		message.action ~= "Join"
		and message.action ~= "Leave"
		and message.action ~= "Steer"
		and message.action ~= "Rematch"
		and message.action ~= "Resync"
	then
		return false, "ACTION"
	end
	local s = message.sequence
	if type(s) ~= "number" or s ~= s or s < 1 or s > Config.MaxSequence or s % 1 ~= 0 then
		return false, "SEQUENCE"
	end
	if message.action == "Steer" then
		if type(message.matchId) ~= "string" or #message.matchId > 128 then
			return false, "MATCH"
		end
		if message.turn ~= -1 and message.turn ~= 0 and message.turn ~= 1 then
			return false, "TURN"
		end
	elseif message.turn ~= nil or message.matchId ~= nil then
		return false, "FIELD"
	end
	return true, "OK"
end
return Protocol
