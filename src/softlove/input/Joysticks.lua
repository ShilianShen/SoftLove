local State = require("softlove.input.State")
local Joysticks = {}

function Joysticks:init()
	self.joysticks = {}
end

function Joysticks:step()
	for _, state in pairs(self.joysticks) do
		State.step(state)
	end
end

---@param id integer
function Joysticks:visit(id)
	return State.visit(self.joysticks[id])
end

function Joysticks:added(joystick)
	local id = joystick:getID()
	self.joysticks[id] = {}
	State.init(self.joysticks[id])
end

function Joysticks:removed(joystick)
	local id = joystick:getID()
	self.joysticks[id] = nil
end

function Joysticks:pressed(joystick, button)
	local id = joystick:getID()
	State.set(self.joysticks[id], button, true)
end

function Joysticks:released(joystick, button)
	local id = joystick:getID()
	State.set(self.joysticks[id], button, false)
end

function Joysticks:axis(joystick, axis, value)
	local id = joystick:getID()
	State.set(self.joysticks[id], axis, value)
end

function Joysticks:hat(joystick, hat, direction)
	local id = joystick:getID()
	State.set(self.joysticks[id], hat, direction)
end

return Joysticks
