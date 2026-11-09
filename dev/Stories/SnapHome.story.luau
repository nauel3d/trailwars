--!strict
local Home = require(script.Parent.Parent.PolishProof.Home)
return function(target: Frame)
	local proof = Home.mount(target)
	return proof.destroy
end
