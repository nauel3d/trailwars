--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("TrailWars")
local Config = require(Shared.Config)
local Catalog = require(Shared.Catalog)
local Economy = require(script.Parent.EconomyService)
local PurchaseService = {}
function PurchaseService.bind(profiles: any, isMock: boolean)
	local productToItem: { [number]: string } = {}
	for _, item in Catalog.Items do
		if item.productId and item.productId > 0 then productToItem[item.productId] = item.id end
	end
	MarketplaceService.ProcessReceipt = function(receipt: any)
		local retry = Enum.ProductPurchaseDecision.NotProcessedYet
		-- Never acknowledge a real receipt from an in-memory/mock environment.
		if isMock or not Config.EnableLivePurchases then return retry end
		local itemId = productToItem[receipt.ProductId]
		if not itemId or not Players:GetPlayerByUserId(receipt.PlayerId) then return retry end
		if type(receipt.PurchaseId) ~= "string" or #receipt.PurchaseId > 200 then return retry end
		local success = profiles:transact(receipt.PlayerId, function(profile: any)
			return Economy.receipt(profile, receipt.PurchaseId, receipt.ProductId, itemId)
		end)
		if not success then return retry end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end
return PurchaseService
