--!strict
local Demos = require(script.Parent.Parent.PolishProof.Demos)
return function(target: Frame)
	local demo = Demos.mount(target, "RESULTS")
	return demo.destroy
end
