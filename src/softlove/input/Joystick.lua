local State = require("softlove.input.State")
local Joystick = {}

function Joystick:init()
	self.joysticks = {}
end

function Joystick:update()
	for _, state in pairs(self.joysticks) do
		State.update(state)
	end
end

function Joystick:isDynamic()
	for _, state in pairs(self.joysticks) do
		if State.isDynamic(state) then
			return true
		end
	end
	return false
end

function Joystick:added(joystick)
	local id = joystick:getID()
	self.joysticks[id] = {}
	State.init(self.joysticks[id])
end

function Joystick:removed(joystick)
	local id = joystick:getID()
	self.joysticks[id] = nil
end

function Joystick:pressed(joystick, button)
	local id = joystick:getID()
	State.set(self.joysticks[id], button, true)
end

function Joystick:released(joystick, button)
	local id = joystick:getID()
	State.set(self.joysticks[id], button, false)
end

function Joystick:axis(joystick, axis, value)
	local id = joystick:getID()
	State.set(self.joysticks[id], axis, value)
end

function Joystick:hat(joystick, hat, direction)
	local id = joystick:getID()
	State.set(self.joysticks[id], hat, direction)
end

return Joystick
