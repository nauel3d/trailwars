--!strict
local Stepper = {}
Stepper.__index = Stepper
function Stepper.new(step: number, maxSteps: number, maxBacklog: number)
	return setmetatable(
		{ step = step, maxSteps = maxSteps, maxBacklog = maxBacklog, accumulator = 0, droppedSeconds = 0, ticks = 0 },
		Stepper
	)
end
function Stepper:advance(dt: number, callback: () -> ())
	if dt ~= dt or dt < 0 or dt == math.huge then
		return 0
	end
	local sum = self.accumulator + dt
	if sum > self.maxBacklog then
		self.droppedSeconds += sum - self.maxBacklog
		sum = self.maxBacklog
	end
	self.accumulator = sum
	local count = 0
	while self.accumulator + 1e-10 >= self.step and count < self.maxSteps do
		self.accumulator -= self.step
		count += 1
		self.ticks += 1
		callback()
	end
	return count
end
return Stepper
