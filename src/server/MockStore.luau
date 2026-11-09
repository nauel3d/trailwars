--!strict
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("TrailWars")
local Schema = require(Shared.ProfileSchema)
local MockStore = {}
MockStore.__index = MockStore
function MockStore.new()
	return setmetatable({ data = {}, fail = false, repeatCallback = false }, MockStore)
end
function MockStore:UpdateAsync(key: string, callback: (any) -> any): any
	if self.fail then
		error("Injected mock store failure")
	end
	if self.repeatCallback then
		callback(Schema.copy(self.data[key]))
	end
	local nextValue = callback(Schema.copy(self.data[key]))
	if nextValue == nil then
		return nil
	end
	self.data[key] = Schema.copy(nextValue)
	return Schema.copy(nextValue)
end
return MockStore
