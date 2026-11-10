--!strict
-- Fault injection against the real store coordinator; no network or DataStore calls.
return function()
	local S = game:GetService("ServerScriptService").TrailWars
	local Store = require(S.ProfileStore)
	local Mock = require(S.MockStore)
	local Economy = require(S.EconomyService)
	local Schema = require(game:GetService("ReplicatedStorage").TrailWars.ProfileSchema)
	local passed = 0
	local function check(value, message)
		assert(value, message)
		passed += 1
	end
	local backend = Mock.new()
	local baseUpdate = backend.UpdateAsync
	local failures, calls, committedError = 2, 0, false
	function backend:UpdateAsync(key, callback)
		calls += 1
		if failures > 0 then
			failures -= 1
			error("Injected throttle")
		end
		local value = baseUpdate(self, key, callback)
		if committedError then
			committedError = false
			error("Injected response loss AFTER durable commit")
		end
		return value
	end
	local waits = 0
	local opts = {
		wait = function()
			waits += 1
		end,
	}
	local owner = Store.new(backend, function()
		return 1000
	end, "owner", opts)
	check(owner:load(1), "transient load throttling recovers")
	check(calls == 3 and waits == 2, "lease retries bounded and backed off")
	check(owner:snapshot(1).coins == 0, "recovered new profile confirmed")
	committedError = true
	calls = 0
	check(not owner:transact(1, function(p)
		return Economy.roundReward(p, "durable-match", true)
	end), "lost response cannot acknowledge a grant")
	check(calls == 1, "generic mutation is never blindly retried")
	check(owner:snapshot(1) == nil, "ambiguous cache hidden")
	check(backend.data.u_1.coins == 15, "fault really followed a committed reward")
	check(owner:load(1), "reconcile durable result")
	check(
		owner:transact(1, function(p)
			return Economy.roundReward(p, "durable-match", true)
		end),
		"caller retries same durable event id"
	)
	check(owner:snapshot(1).coins == 15, "uncertain response does not duplicate reward")
	committedError = true
	check(owner:release(1) == false, "lost release response may conservatively report session lost")
	check(backend.data.u_1.lease == nil, "committed release did not resurrect its lock")
	local reconnect = Store.new(backend, function()
		return 1000
	end, "reconnect", opts)
	check(reconnect:load(1), "rapid reconnect acquires released lease")
	check(reconnect:snapshot(1).coins == 15, "reconnect preserves previous rewards")
	local old = Schema.copy(backend.data.u_1)
	failures = 20
	calls = 0
	local failed = Store.new(backend, function()
		return 1000
	end, "unavailable", opts)
	check(not failed:load(1), "sustained failure rejected")
	check(calls == 3 and failed:snapshot(1) == nil, "bounded failed load provides no defaults")
	check(backend.data.u_1.coins == old.coins, "load failure never overwrites valid coins")
	check(backend.data.u_1.lease.owner == "reconnect", "load failure never clears another session")
	failed.stopped = true
	check(not failed:load(2), "shutdown prevents new loads")
	check(backend.data.u_2 == nil, "shutdown creates no defaults")
	print(string.format("LAUNCH RELIABILITY: %d assertions passed (fault-injected, not live DataStore)", passed))
	return { passed = passed, failed = 0 }
end
