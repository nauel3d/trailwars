--!strict
local Board = {}
function Board.mount(parent: Instance, Kit: any, Motion: any, preferences: any)
	local root = Kit.panel(parent, "MatchStandings")
	root.ZIndex = 12
	local title = Kit.text(root, "Title", "MATCH STANDINGS", 17)
	title.ZIndex = 14
	title.Size = UDim2.new(1, -16, 0, 30)
	title.Position = UDim2.fromOffset(8, 0)
	local scope = Motion.new(root, { preferences = preferences })
	local rows = {}
	local generation = 0
	local lastLedger = nil
	local busy = false
	local wasLarge = false
	local function set(data: any, ledger: any, animate: boolean)
		data = table.clone(data)
		table.sort(data, function(a, b)
			if a.rank ~= b.rank then
				return a.rank < b.rank
			end
			return a.id < b.id
		end)
		if not animate and wasLarge then
			generation += 1
			busy = false
			scope:cancel()
		end
		wasLarge = animate
		local fresh = animate and ledger and ledger.roundId ~= lastLedger
		if fresh then
			generation += 1
			lastLedger = ledger.roundId
			scope:cancel()
			busy = true
		end
		local gen = generation
		local awards = {}
		for _, a in if ledger then ledger.awards else {} do
			awards[a.id] = a
		end
		local height = math.max(28, math.min(48, (root.AbsoluteSize.Y - 38) / math.max(1, #data)))
		for i, p in data do
			local row = rows[p.id]
			if not row then
				local face = Kit.frame(root, p.id, Kit.colors.paper)
				face.ZIndex = 13
				Kit.round(face, 8)
				local fill = Kit.frame(face, "Progress", Kit.colors.mint)
				fill.Size = UDim2.fromScale(0, 1)
				fill.ZIndex = 13
				Kit.round(fill, 8)
				local label = Kit.text(face, "Label", "", 14)
				label.ZIndex = 14
				label.Size = UDim2.new(1, -90, 1, 0)
				label.Position = UDim2.fromOffset(8, 0)
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextWrapped = false
				label.TextTruncate = Enum.TextTruncate.AtEnd
				local total = Kit.text(face, "Total", "", 16)
				total.ZIndex = 14
				total.Size = UDim2.new(0, 80, 1, 0)
				total.Position = UDim2.new(1, -84, 0, 0)
				row = { face = face, fill = fill, label = label, total = total }
				rows[p.id] = row
			end
			row.face.Size = UDim2.new(1, -16, 0, height - 3)
			row.label.Text = tostring(p.rank) .. "  " .. p.name
			local target = UDim2.fromOffset(8, 34 + (i - 1) * height)
			local a = awards[p.id]
			local function final()
				if gen ~= generation then
					return
				end
				row.total.Text = tostring(p.score)
				scope:to(row.fill, { Size = UDim2.fromScale(math.min(1, p.score / 100), 1) }, "celebrate")
				scope:after(0.5, function()
					if gen == generation then
						scope:to(row.face, { Position = target }, "reorder")
					end
				end)
			end
			if fresh and a and not scope:isReduced() then
				row.total.Text = tostring(a.before)
				scope:after(0.25, function()
					if gen == generation then
						row.total.Text = string.format("%d %+d", a.before, a.delta)
					end
				end)
				scope:after(0.65, final)
			elseif not busy or scope:isReduced() then
				row.total.Text = tostring(p.score)
				row.face.Position = target
				row.fill.Size = UDim2.fromScale(math.min(1, p.score / 100), 1)
			end
			if fresh and row.face.Position == UDim2.new() then
				row.face.Position = target
			end
		end
		if fresh then
			scope:after(1.5, function()
				if gen == generation then
					busy = false
				end
			end)
		end
	end
	return {
		root = root,
		title = title,
		set = set,
		setReducedMotion = function(value)
			scope:setReducedMotion(value)
		end,
		skip = function()
			generation += 1
			busy = false
			scope:cancel()
		end,
		destroy = function()
			scope:destroy()
			root:Destroy()
		end,
	}
end
return Board
