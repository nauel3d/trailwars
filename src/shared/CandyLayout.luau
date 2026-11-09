--!strict
-- Presentation only. The 1300:800 authoritative world is never stretched.
local Layout = {}
function Layout.compute(w: number, h: number)
	local landscape = w > h and h < 500
	local desktop = w >= 1000 and h >= 600
	local pad = if w < 500 or landscape then 8 else 20
	local header = if landscape then 48 else 60
	local side = if desktop then 224 elseif landscape then 156 else 0
	local bottom = if landscape then 12 else 144
	local aw = w - side - pad * 2
	local ah = math.max(1, h - header - bottom - 12)
	local fw = math.min(aw, ah * 1300 / 800)
	local fh = fw * 800 / 1300
	local fy = if desktop or landscape then header + (ah - fh) / 2 else header + 16
	local field = { pad + (aw - fw) / 2, fy, fw, fh }
	local left, right, homing, jump, status
	if landscape then
		local x = w - side + 4
		homing = { x, 60, side - 16, 54 }
		jump = { x, 122, side - 16, 54 }
		left = { x, h - 66, 64, 56 }
		right = { x + 72, h - 66, 64, 56 }
		status = { x, 182, side - 16, math.max(30, h - 252) }
	else
		local cw = math.clamp(w * 0.18, 64, 104)
		left = { pad, h - 72, cw, 60 }
		right = { w - cw - pad, h - 72, cw, 60 }
		local bw = math.min(260, (w - pad * 2 - 12) / 2)
		homing = { (w - bw * 2 - 12) / 2, h - 136, bw, 54 }
		jump = { (w + 12) / 2, h - 136, bw, 54 }
		status = { cw + pad + 8, h - 70, w - 2 * (cw + pad + 8), 54 }
	end
	return {
		field = field,
		pad = pad,
		landscape = landscape,
		desktop = desktop,
		left = left,
		right = right,
		homing = homing,
		jump = jump,
		status = status,
		header = { pad, 0, w - 100 - pad * 2, header },
		home = { w - 88 - pad, 0, 88, 44 },
		feedback = if desktop then { w - 212, header + 320, 192, 64 } else { field[1], field[2] + fh + 10, fw, 28 },
		standings = { w - 212, header + 16, 192, 280 },
	}
end
return Layout
