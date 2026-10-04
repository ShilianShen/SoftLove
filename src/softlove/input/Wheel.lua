local State = require("softlove.input.State")
local Wheel = {
	init = State.init,
	step = State.step,
}

function Wheel.moved(self, dx, dy)
	State.set(self, "dx", dx)
	State.set(self, "dy", dy)
end

return Wheel
