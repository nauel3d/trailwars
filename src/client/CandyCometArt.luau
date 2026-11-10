--!strict
-- Original, resolution-independent source graphics. No uploaded images or runtime asset fetches.
local Art = {}
function Art.core(parent: Instance, Kit: any, color: Color3)
	local function shape(name, paint, x, y, w, h, z)
		local f = Kit.frame(parent, name, paint)
		f.Position = UDim2.fromScale(x, y)
		f.Size = UDim2.fromScale(w, h)
		f.ZIndex = z
		Kit.round(f, 99)
		return f
	end
	local ink, paper = Kit.colors.ink, Kit.colors.paper
	local shell = shape("Shell", color, 0, 0, 1, 1, 5)
	local stroke = Kit.outline(shell, ink, 1.5)
	local shade = shape("LowerCandy", color:Lerp(ink, 0.22), 0.08, 0.18, 0.86, 0.76, 6)
	local face = shape("CandyTop", color, 0.08, 0.03, 0.84, 0.77, 7)
	local rim = shape("CandyRim", color:Lerp(paper, 0.55), 0.16, 0.72, 0.56, 0.14, 8)
	local visor = shape("Visor", ink, 0.43, 0.22, 0.47, 0.55, 8)
	local function eye(y)
		local f = Kit.frame(visor, "Eye", paper)
		f.Position = UDim2.fromScale(0.4, y)
		f.Size = UDim2.fromScale(0.23, 0.23)
		f.ZIndex = 9
		Kit.round(f, 99)
	end
	eye(0.16)
	eye(0.61)
	local shine = shape("Specular", paper, 0.18, 0.14, 0.24, 0.14, 9)
	shine.Rotation = -35
	return { shell = shell, bodyStroke = stroke, rim = rim, visor = visor, spec = shine, shade = shade, face = face }
end
function Art.rocket(parent: Instance, Kit: any, turret: boolean)
	local function part(name, color, x, y, w, h, z)
		local f = Kit.frame(parent, name, color)
		f.Position = UDim2.fromScale(x, y)
		f.Size = UDim2.fromScale(w, h)
		f.ZIndex = z
		Kit.round(f, 3)
		return f
	end
	local ink = Kit.colors.ink
	local color = if turret then Kit.colors.yellow else Kit.colors.coral
	local flame = part("Exhaust", Kit.colors.yellow, -0.3, 0.34, 0.4, 0.32, 6)
	Kit.round(flame, 99)
	part("FinTop", ink, 0.1, 0.02, 0.4, 0.3, 7).Rotation = -25
	part("FinBottom", ink, 0.1, 0.68, 0.4, 0.3, 7).Rotation = 25
	local hull = part("Hull", Kit.colors.paper, 0.08, 0.24, 0.74, 0.52, 8)
	Kit.round(hull, 99)
	Kit.outline(hull, ink, 1)
	local nose = part("Nose", color, 0.65, 0.26, 0.3, 0.48, 9)
	Kit.round(nose, 99)
	local window = part("Window", ink, 0.46, 0.35, 0.17, 0.3, 9)
	Kit.round(window, 99)
	local wings = part("TurretWings", color, 0.12, -0.04, 0.16, 1.08, 8)
	local stripe = part("Stripe", color, 0.2, 0.28, 0.12, 0.44, 9)
	wings.Visible = turret
	stripe.Visible = not turret
	return flame
end
return Art
