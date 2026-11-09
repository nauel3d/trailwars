--!strict
local Demos = require(script.Parent.Parent.PolishProof.Demos)
return function(target: Frame)
	local demo = Demos.mount(target, "SHOP")
	return demo.destroy
end
