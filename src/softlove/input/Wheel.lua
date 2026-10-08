local State = require("softlove.input.State")
local Wheel = {
	init = State.init,
	step = State.step,
}

---@alias softlove.input.WheelKeys "dx"|"dy"

---@class softlove.input.WheelState
---@field dx? number
---@field dy? number

---@class softlove.input.Wheel: softlove.input.State<softlove.input.WheelKeys>
---@field visit fun(self: softlove.input.Wheel): softlove.input.WheelState, softlove.input.WheelState

---@param self softlove.input.Wheel
---@param dx number
---@param dy number
function Wheel.moved(self, dx, dy)
	State.set(self, "dx", dx)
	State.set(self, "dy", dy)
end

return Wheel
