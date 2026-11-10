--!strict
local Art = require(script.Parent.CandyCometArt)
local Tokens = require(game.ReplicatedStorage.TrailWars.GameplayMotion)
local Cues = require(game.ReplicatedStorage.TrailWarsDev.UICues)
local Board = {}
function Board.mount(parent: Instance, Kit: any, Motion: any, preferences: any)
	local root = Kit.panel(parent, "MatchStandings")
	root.ZIndex = 12
	root.ClipsDescendants = true
	local title = Kit.text(root, "Title", "LIVE STANDINGS", 16)
	title.ZIndex = 14
	title.Size = UDim2.new(1, -16, 0, 32)
	title.Position = UDim2.fromOffset(8, 0)
	local scope = Motion.new(root, { preferences = preferences })
	local rows = {}
	local generation, lastLedger, lastKey, busy, wasLarge = 0, nil, nil, false, false
	local function release(row)
		scope:cancel(row.count)
		scope:cancel(row.fill)
		scope:cancel(row.face)
		row.connection:Disconnect()
		row.face:Destroy()
	end
	local function set(data, ledger, large, styles, targetScore)
		data = table.clone(data)
		table.sort(data, function(a, b)
			return if a.rank == b.rank then a.id < b.id else a.rank < b.rank
		end)
		if not large and wasLarge then
			generation += 1
			busy = false
			scope:cancel()
		end
		wasLarge = large
		local fresh = large and ledger and ledger.roundId ~= lastLedger
		local key = tostring(root.AbsoluteSize)
			.. tostring(large)
			.. tostring(ledger and ledger.roundId)
			.. tostring(targetScore)
		for _, p in data do
			key ..= p.id .. p.name .. p.rank .. ":" .. p.score
		end
		if key == lastKey and not fresh then
			return
		end
		lastKey = key
		if fresh then
			generation += 1
			lastLedger = ledger.roundId
			scope:cancel()
			busy = true
		end
		local gen = generation
		local awards, seen = {}, {}
		for _, a in if ledger then ledger.awards else {} do
			awards[a.id] = a
		end
		local height = math.min(48, math.max(20, (root.AbsoluteSize.Y - 42) / math.max(1, #data)))
		local target = math.max(1, targetScore or 100)
		for i, p in data do
			seen[p.id] = true
			local row = rows[p.id]
			if not row then
				local face = Kit.frame(root, p.id, Kit.colors.paper)
				face.ZIndex = 13
				Kit.round(face, 9)
				Kit.outline(face, Kit.colors.ink, 1)
				local fill = Kit.frame(face, "Progress", Kit.colors.mint)
				fill.ZIndex = 13
				Kit.round(fill, 9)
				local avatar = Kit.frame(face, "RacerBadge")
				avatar.Size = UDim2.fromOffset(22, 22)
				avatar.Position = UDim2.new(0, 8, 0.5, -11)
				avatar.ZIndex = 14
				Art.core(avatar, Kit, if styles and styles[p.id] then styles[p.id].color else Kit.colors.coral)
				for _, x in avatar:GetDescendants() do
					if x:IsA("GuiObject") then
						x.ZIndex += 9
					end
				end
				local label = Kit.text(face, "Label", "", 14)
				label.ZIndex = 15
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextWrapped = false
				label.TextTruncate = Enum.TextTruncate.AtEnd
				local total = Kit.text(face, "Total", "", 17)
				total.ZIndex = 15
				total.Position = UDim2.new(1, -65, 0, 0)
				total.Size = UDim2.new(0, 58, 1, 0)
				local delta = Kit.text(face, "Delta", "", 14, Kit.colors.blue)
				delta.ZIndex = 15
				delta.Position = UDim2.new(1, -123, 0, 0)
				delta.Size = UDim2.new(0, 58, 1, 0)
				local count = Instance.new("NumberValue")
				count.Parent = face
				local connection = count.Changed:Connect(function(v)
					total.Text = tostring(math.round(v))
				end)
				row = {
					face = face,
					fill = fill,
					label = label,
					total = total,
					delta = delta,
					count = count,
					avatar = avatar,
					connection = connection,
				}
				rows[p.id] = row
			end
			row.face.Size = UDim2.new(1, -16, 0, height - 4)
			row.label.TextSize = if height < 30 then 12 else 14
			row.avatar.Visible = large and height >= 30
			local labelX = if row.avatar.Visible then 38 else 8
			row.label.Position = UDim2.fromOffset(labelX, 0)
			row.label.Size = UDim2.new(1, -labelX - (if large then 128 else 66), 1, 0)
			row.delta.Visible = large
			local position = UDim2.fromOffset(8, 36 + (i - 1) * height)
			local label = tostring(p.rank) .. "  " .. p.name
			local award = awards[p.id]
			local rose = row.rank and p.rank < row.rank
			if fresh and award and not scope:isReduced() then
				row.label.Text = tostring(row.rank or p.rank) .. "  " .. p.name
				row.count.Value = award.before
				row.total.Text = tostring(award.before)
				row.fill.Size = UDim2.fromScale(math.clamp(award.before / target, 0, 1), 1)
				row.delta.Text = ""
				scope:after(Tokens.DeltaHold, function()
					if gen == generation then
						row.delta.Text = string.format("%+d", award.delta)
						row.delta.TextColor3 = if award.delta < 0 then Kit.colors.coral else Kit.colors.blue
					end
				end)
				scope:after(Tokens.ScoreStart, function()
					if gen == generation then
						scope:to(row.count, { Value = p.score }, "scoreFill")
						scope:to(
							row.fill,
							{ Size = UDim2.fromScale(math.clamp(p.score / target, 0, 1), 1) },
							"scoreFill"
						)
					end
				end)
				scope:after(Tokens.ReorderStart, function()
					if gen == generation then
						row.label.Text = label
						scope:to(row.face, { Position = position }, "rankMove")
						if rose then
							row.face.Rotation = -1.5
							scope:to(row.face, { Rotation = 0 }, "settle")
							Cues.play(root, "rank", preferences)
						end
					end
				end)
			elseif not busy or scope:isReduced() then
				row.count.Value = p.score
				row.total.Text = tostring(p.score)
				row.label.Text = label
				row.face.Position = position
				row.fill.Size = UDim2.fromScale(math.clamp(p.score / target, 0, 1), 1)
				if not large then
					row.delta.Text = ""
				elseif award then
					row.delta.Text = string.format("%+d", award.delta)
				end
			end
			if row.face.Position == UDim2.new() then
				row.face.Position = position
			end
			row.rank = p.rank
		end
		for id, row in rows do
			if not seen[id] then
				generation += 1
				busy = false
				scope:cancel()
				lastKey = nil
				release(row)
				rows[id] = nil
			end
		end
		if fresh then
			scope:after(Tokens.ScoreEnd, function()
				if gen == generation then
					busy = false
					lastKey = nil
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
			lastKey = nil
		end,
		skip = function()
			generation += 1
			busy = false
			scope:cancel()
			lastKey = nil
		end,
		destroy = function()
			generation += 1
			scope:destroy()
			for _, row in rows do
				release(row)
			end
			root:Destroy()
		end,
	}
end
return Board
