local State = require("softlove.input.State")
local Wheel = {}
local signals = {
	dx = 0,
	dy = 0,
}

function Wheel.init(self)
	State.init(self, signals)
end

function Wheel.moved(self, dx, dy)
	self.s3.dx = dx
	self.s3.dy = dy
end

return Wheel
