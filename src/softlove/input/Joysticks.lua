local State = require("softlove.input.State")
local Joysticks = {}

function Joysticks.init(self)
	self.joysticks = {}
end

function Joysticks.step(self)
	for _, state in pairs(self.joysticks) do
		State.step(state)
	end
end

---@param id integer
function Joysticks.visit(self, id)
	return State.visit(self.joysticks[id])
end

function Joysticks.added(self, joystick)
	local id = joystick:getID()
	self.joysticks[id] = {}
	State.init(self.joysticks[id])
end

function Joysticks.removed(self, joystick)
	local id = joystick:getID()
	self.joysticks[id] = nil
end

function Joysticks.pressed(self, joystick, button)
	local id = joystick:getID()
	State.set(self.joysticks[id], button, true)
end

function Joysticks.released(self, joystick, button)
	local id = joystick:getID()
	State.set(self.joysticks[id], button, false)
end

function Joysticks.axis(self, joystick, axis, value)
	local id = joystick:getID()
	State.set(self.joysticks[id], axis, value)
end

function Joysticks.hat(self, joystick, hat, direction)
	local id = joystick:getID()
	State.set(self.joysticks[id], hat, direction)
end

return Joysticks
