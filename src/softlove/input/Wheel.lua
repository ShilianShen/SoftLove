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
	State.set(self, "dx", dx)
	State.set(self, "dy", dy)
end

return Wheel
