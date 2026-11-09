--!strict
local Board = require(script.Parent.Parent.PolishProof.ComponentBoard)
return function(target: Frame)
	return Board.mount(target)
end
