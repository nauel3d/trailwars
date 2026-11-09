--!strict
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.TrailWars.GameplayConfig)
local Sim = require(RS.TrailWars.Simulation)
local Replica = require(RS.TrailWars.GameplayReplica)
local Transport = {}
function Transport.new()
	local remote = RS.TrailWars:WaitForChild("GameplayIntent") :: RemoteEvent
	local frames = RS.TrailWars:WaitForChild("GameplayFrame") :: RemoteEvent
	local replica = Replica.new()
	local client: any = {
		selfId = "u" .. game:GetService("Players").LocalPlayer.UserId,
		sequence = 0,
		state = nil,
		pending = {},
		matchId = nil,
		received = 0,
		reset = false,
		elapsed = 0,
		age = 0,
		lastTurn = 0,
		wanted = false,
	}
	function client:send(action: string, turn: number?)
		self.sequence += 1
		remote:FireServer({
			action = action,
			sequence = self.sequence,
			matchId = if action == "Steer" then self.matchId else nil,
			turn = turn,
		})
	end
	local connection = frames.OnClientEvent:Connect(function(packet)
		if not client.wanted then
			return
		end
		local accepted, code = replica:accept(packet)
		if not accepted then
			if code == "RESYNC" and os.clock() - (client.lastResync or -100) >= 1 then
				client.lastResync = os.clock()
				client:send("Resync")
			end
			return
		end
		client.matchId = replica.matchId
		client.reset = client.reset or replica.reset
		replica.reset = false
		client.authoritative = replica.state
		client.state = replica.state
		client.age = 0
	end)
	function client:join()
		self.wanted = true
		self:send("Join")
	end
	function client:leave()
		self.wanted = false
		replica:clear()
		self:send("Leave")
		self.state = nil
		self.authoritative = nil
		self.pending = {}
		self.received = 0
		self.matchId = nil
		self.reset = true
	end
	function client:step(dt: number, turn: number)
		self.elapsed += dt
		self.age = math.min(0.15, self.age + dt)
		local a = self.authoritative
		if not a then
			return
		end
		if self.wanted and a.phase == "Active" and (turn ~= self.lastTurn or self.elapsed >= 0.1) then
			self.lastTurn = turn
			self.elapsed = 0
			self:send("Steer", turn)
		end
		-- Bounded visual extrapolation only; authoritative geometry and deaths never predicted.
		local display = table.clone(a)
		display.players = {}
		for _, p in a.players do
			local q = table.clone(p)
			if p.alive and a.phase == "Active" then
				local nextState = Sim.motion(p, if p.id == self.selfId then turn else p.turn, self.age, Config, a.time)
				q.x = math.clamp(nextState.x, Config.CoreRadius, Config.Width - Config.CoreRadius)
				q.y = math.clamp(nextState.y, Config.CoreRadius, Config.Height - Config.CoreRadius)
				q.heading = nextState.heading
			end
			table.insert(display.players, q)
		end
		self.state = display
	end
	function client:drain()
		return replica:drain()
	end
	function client:destroy()
		connection:Disconnect()
	end
	return client
end
return Transport
