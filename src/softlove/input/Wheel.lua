local State = require("softlove.input.State")
local Wheel = {
	init = State.init,
	update = State.update,
	isDynamic = State.isDynamic,
}

function Wheel.moved(self, dx, dy)
	State.set(self, "dx", dx)
	State.set(self, "dy", dy)
end

return Wheel
