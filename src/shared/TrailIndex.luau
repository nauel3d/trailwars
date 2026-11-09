--!strict
local Index = {}
Index.__index = Index
function Index.new(cell: number)
	return setmetatable({ cell = cell, cells = {}, segments = {}, queries = 0, candidates = 0 }, Index)
end
function Index:insert(segment: any)
	local id = #self.segments + 1
	segment.id = id
	self.segments[id] = segment
	for x = math.floor(math.min(segment.ax, segment.bx) / self.cell), math.floor(math.max(segment.ax, segment.bx) / self.cell) do
		for y = math.floor(math.min(segment.ay, segment.by) / self.cell), math.floor(math.max(segment.ay, segment.by) / self.cell) do
			local key = x .. ":" .. y
			local bucket = self.cells[key]
			if not bucket then
				bucket = {}
				self.cells[key] = bucket
			end
			table.insert(bucket, id)
		end
	end
	return id
end
function Index:query(ax: number, ay: number, bx: number, by: number, r: number)
	self.queries += 1
	local result, seen = {}, {}
	for x = math.floor((math.min(ax, bx) - r) / self.cell), math.floor((math.max(ax, bx) + r) / self.cell) do
		for y = math.floor((math.min(ay, by) - r) / self.cell), math.floor((math.max(ay, by) + r) / self.cell) do
			local bucket = self.cells[x .. ":" .. y]
			if bucket then
				for _, id in bucket do
					if not seen[id] then
						seen[id] = true
						table.insert(result, self.segments[id])
					end
				end
			end
		end
	end
	self.candidates += #result
	return result
end
return Index
