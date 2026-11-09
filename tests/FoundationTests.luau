--!strict
-- Run in Studio Command Bar with this file imported as a ModuleScript.
-- return require(path.to.FoundationTests)()  -- no real DataStore calls.
return function()
	local Shared = game:GetService("ReplicatedStorage"):WaitForChild("TrailWars")
	local Server = game:GetService("ServerScriptService"):WaitForChild("TrailWars")
	local Schema = require(Shared.ProfileSchema)
	local Economy = require(Server.EconomyService)
	local Store = require(Server.ProfileStore)
	local Mock = require(Server.MockStore)
	local assertions = 0
	local function check(value: boolean, label: string)
		assert(value, label)
		assertions += 1
	end
	local profile = Schema.new()
	check(not Economy.equip(profile, "core_ring"), "unowned equip rejected")
	check(not Economy.buyEarned(profile, "core_ring"), "insufficient funds rejected")
	check(not Economy.setting(profile, "music", 0 / 0), "NaN rejected")
	check(not Economy.setting(profile, "coins", 999), "unknown setting rejected")
	profile.coins = 200
	check(Economy.buyEarned(profile, "core_ring"), "earned purchase granted")
	check(profile.coins == 50 and profile.owned.core_ring, "cost and ownership atomic mutation")
	check(not Economy.buyEarned(profile, "core_ring"), "duplicate earned purchase rejected")
	check(profile.coins == 50, "duplicate did not charge")
	check(Economy.equip(profile, "core_ring"), "owned equip accepted")
	check(Economy.receipt(profile, "purchase-1", 123, "core_ring"), "receipt granted")
	check(Economy.receipt(profile, "purchase-1", 123, "core_ring"), "receipt replay acknowledged")
	check(not Economy.receipt(profile, "purchase-1", 124, "core_ring"), "receipt conflict rejected")
	check(Economy.roundReward(profile, "match-1", true), "reward granted")
	check(Economy.roundReward(profile, "match-1", true), "reward replay acknowledged")
	check(profile.stats.wins == 1 and profile.coins == 65, "reward replay did not duplicate")
	local bad = Schema.new()
	bad.version = 999
	check(Schema.migrate(bad) == nil, "future schema rejected")
	local public = Schema.public(profile)
	check(public.receipts == nil and public.rewards == nil and public.lease == nil, "internal data excluded")
	local now = 1000
	local backend = Mock.new()
	backend.repeatCallback = true
	local a = Store.new(backend, function()
		return now
	end, "a")
	local b = Store.new(backend, function()
		return now
	end, "b")
	backend.fail = true
	check(not a:load(42), "initial failed load rejected")
	check(a:snapshot(42) == nil, "failed load never supplies writable defaults")
	backend.fail = false
	check(a:load(42), "later explicit load recovers after outage")
	check(a:snapshot(42) ~= nil, "recovered load exposes confirmed profile")
	local delayedBackend = Mock.new()
	local baseUpdate = delayedBackend.UpdateAsync
	local suspendWrite = false
	function delayedBackend:UpdateAsync(key: string, callback: (any) -> any): any
		if suspendWrite then
			coroutine.yield("WRITE_PENDING")
		end
		return baseUpdate(self, key, callback)
	end
	local delayed = Store.new(delayedBackend, function()
		return now
	end, "delayed")
	check(delayed:load(7), "delayed fixture profile acquired")
	suspendWrite = true
	local committed = false
	local writer = coroutine.create(function()
		committed = delayed:transact(7, function(p: any)
			p.coins += 20
			return true, "OK"
		end)
	end)
	local resumed, yielded = coroutine.resume(writer)
	check(resumed and yielded == "WRITE_PENDING", "write suspended before durable commit")
	check(delayed:isBusy(7), "pending durable write reports busy")
	check(delayed:snapshot(7) == nil, "pending write cannot reconcile stale cache")
	check(coroutine.resume(writer), "pending write resumed")
	check(committed and not delayed:isBusy(7), "committed write releases busy gate")
	check(delayed:snapshot(7).coins == 20, "reconciliation sees committed result")
	check(a:load(1), "first session acquired")
	check(not b:load(1), "second server rejected")
	backend.fail = true
	check(not a:transact(1, function(p: any)
		p.coins += 100
		return true, "OK"
	end), "failed persistence rejected")
	backend.fail = false
	check(a:snapshot(1).coins == 0, "failed persistence did not update cache")
	check(
		a:transact(1, function(p: any)
			return Economy.roundReward(p, "m1", true)
		end),
		"committed reward"
	)
	check(a:snapshot(1).coins == 15, "callback retry did not multiply reward")
	now = 1201
	check(b:load(1), "expired lease acquired by new server")
	check(not a:transact(1, function(p: any)
		p.coins += 999
		return true, "OK"
	end), "stale server write rejected")
	check(a:snapshot(1) == nil, "stale cache hidden")
	check(b:snapshot(1).coins == 15, "new server preserved balance")
	check(b:release(1), "owner released lock")
	check(a:load(1), "released lock acquired")
	return { passed = assertions, failed = 0, environment = "Studio mock store; no live persistence or purchases" }
end
