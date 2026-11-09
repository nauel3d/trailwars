--!strict
-- Full-bleed art and explicitly inset interactive content are separate layers.
local GuiService = game:GetService("GuiService")
local Home = require(script.Parent.Home)
local Kit = require(script.Parent.Components)
local Shell = {}
function Shell.mount(parent: Instance)
	local gui = Instance.new("ScreenGui")
	gui.Name = "TrailWarsSnapProof"
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.None
	gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	gui.ClipToDeviceSafeArea = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent
	local background = Kit.frame(gui, "FullBleedPaper", Kit.colors.paper)
	background.Size = UDim2.fromScale(1, 1)
	local safe = Kit.frame(gui, "SafeArea")
	local function arrange()
		local full = GuiService:GetInsetArea(Enum.ScreenInsets.None)
		local area = GuiService:GetInsetArea(Enum.ScreenInsets.CoreUISafeInsets)
		local origin = area.Min - full.Min
		Kit.box(safe, { origin.X, origin.Y, area.Width, area.Height })
	end
	local connections = {
		gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(arrange),
		GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(arrange),
	}
	arrange()
	local proof = Home.mount(safe)
	return {
		gui = gui,
		proof = proof,
		arrange = arrange,
		destroy = function()
			for _, c in connections do
				c:Disconnect()
			end
			proof.destroy()
			gui:Destroy()
		end,
	}
end
return Shell
