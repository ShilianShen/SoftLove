local State = require("softlove.input.State")
local Wheel = {}

function Wheel.init(self)
	State.init(self)
end

function Wheel.moved(self, dx, dy)
	State.set(self, "dx", dx)
	State.set(self, "dy", dy)
end

return Wheel
