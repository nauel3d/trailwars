--!strict
local Kit = require(script.Parent.Components)
local Motion = require(script.Parent.Motion)
local Rank = require(script.Parent.RankModel)
local Leaderboard = {}
function Leaderboard.mount(parent: Instance, options: any?)
	local opts = options or {}
	local root = Kit.panel(parent, "DemoStandings")
	local motion = Motion.new(root, opts)
	local title = Kit.text(root, "StandingsLabel", if opts.demo ~= false then "DEMO STANDINGS" else "STANDINGS", 14)
	title.Size = UDim2.new(1, -12, 0, 22)
	title.Position = UDim2.fromOffset(6, 0)
	local rows: any = {}
	local last: any = {}
	local snapshot: any = {}
	local dead = false
	local function setRows(data: any, instant: boolean?)
		if dead then
			return
		end
		snapshot = data
		local ordered = Rank.order(data)
		local alive = {}
		local height = math.max(22, (root.AbsoluteSize.Y - 26) / math.max(1, #ordered))
		for rank, item in ordered do
			alive[item.id] = true
			local row = rows[item.id]
			local fresh = row == nil
			if fresh then
				local face = Kit.frame(root, item.id, Kit.colors.paper)
				Kit.round(face, 8)
				local name = Kit.text(face, "Competitor", "", 14)
				name.Position = UDim2.fromOffset(8, 0)
				name.Size = UDim2.new(1, -56, 1, 0)
				name.TextXAlignment = Enum.TextXAlignment.Left
				local score = Kit.text(face, "Score", "", 14)
				score.Position = UDim2.new(1, -48, 0, 0)
				score.Size = UDim2.new(0, 42, 1, 0)
				row = { face = face, name = name, score = score }
				rows[item.id] = row
			end
			local improved = last[item.id] and rank < last[item.id]
			row.name.Text = tostring(item.finalRank or rank) .. "  " .. item.name
			row.score.Text = if item.eliminated then "OUT" else tostring(item.score)
			row.name.TextTransparency = if item.eliminated then 0.4 else 0
			row.face.Size = UDim2.new(1, -12, 0, height - 2)
			local target = UDim2.fromOffset(6, 24 + (rank - 1) * height)
			if instant or fresh then
				motion:cancel(row.face)
				row.face.Position = target
			else
				motion:to(row.face, { Position = target }, "reorder")
			end
			if improved and not opts.hud and not item.finalRank then
				row.face.BackgroundColor3 = if item.id == opts.selfId
					then Kit.colors.mint
					else Color3.fromRGB(236, 239, 255)
				if item.id == opts.selfId then
					row.name.Text ..= " ↑"
				end
				motion:to(row.face, { BackgroundColor3 = Kit.colors.paper }, "celebrate")
				if not motion:isReduced() then
					row.name.Position = UDim2.fromOffset(8, -2)
					motion:to(row.name, { Position = UDim2.fromOffset(8, 0) }, "settle")
				end
			end
			last[item.id] = rank
		end
		for id, row in rows do
			if not alive[id] then
				motion:cancel(row.face)
				row.face:Destroy()
				rows[id] = nil
				last[id] = nil
			end
		end
	end
	motion:connect(root:GetPropertyChangedSignal("AbsoluteSize"), function()
		setRows(snapshot, true)
	end)
	return {
		root = root,
		setRows = setRows,
		setReducedMotion = function(value: boolean)
			motion:setReducedMotion(value)
		end,
		destroy = function()
			dead = true
			motion:destroy()
			root:Destroy()
		end,
	}
end
return Leaderboard
