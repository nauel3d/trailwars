--!strict
local Rank = {}
function Rank.order(rows: any)
	assert(#rows <= 8, "Leaderboard preview limit is 8 rows")
	local out, seen = {}, {}
	local finalCount = 0
	local finalRanks = {}
	for _, r in rows do
		assert(type(r.id) == "string" and not seen[r.id], "Rows require unique stable string IDs")
		assert(
			type(r.score) == "number" and r.score == r.score and math.abs(r.score) < math.huge,
			"Score must be finite"
		)
		seen[r.id] = true
		assert(type(r.name) == "string", "Competitor name must be text")
		if r.finalRank ~= nil then
			assert(
				type(r.finalRank) == "number"
					and r.finalRank % 1 == 0
					and r.finalRank >= 1
					and r.finalRank <= #rows
					and not finalRanks[r.finalRank],
				"Final ranks must be unique places within the row set"
			)
			finalRanks[r.finalRank] = true
			finalCount += 1
		end
		table.insert(
			out,
			{ id = r.id, name = r.name, score = r.score, eliminated = r.eliminated == true, finalRank = r.finalRank }
		)
	end
	assert(finalCount == 0 or finalCount == #rows, "Final placement must describe every row")
	table.sort(out, function(a, b)
		if a.finalRank and b.finalRank and a.finalRank ~= b.finalRank then
			return a.finalRank < b.finalRank
		end
		if a.eliminated ~= b.eliminated then
			return not a.eliminated
		end
		if a.score ~= b.score then
			return a.score > b.score
		end
		return a.id < b.id
	end)
	return out
end
return Rank
