--!strict
export type Item = {
	id: string, name: string, slot: string, starter: boolean,
	earnedCost: number?, productId: number?,
}
-- Semantic content only: final visual styling awaits the reference audit.
local items: { Item } = {
	{ id = "core_default", name = "Starter core", slot = "core", starter = true },
	{ id = "trail_default", name = "Starter trail", slot = "trail", starter = true },
	{ id = "trail_dashed", name = "Dashed trail", slot = "trail", starter = false, earnedCost = 100 },
	{ id = "core_ring", name = "Ring core", slot = "core", starter = false, earnedCost = 150 },
}
local byId: { [string]: Item } = {}
for _, item in items do
	table.freeze(item)
	byId[item.id] = item
end
return table.freeze({ Items = table.freeze(items), ById = table.freeze(byId) })
