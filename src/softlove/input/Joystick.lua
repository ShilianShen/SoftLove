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
	self.joysticks[joystick] = {}
	State.init(self.joysticks[joystick])
end

function Joystick:removed(joystick)
	self.joysticks[joystick] = nil
end

function Joystick:pressed(joystick, button)
	State.set(self.joysticks[joystick], button, true)
end

function Joystick:released(joystick, button)
	State.set(self.joysticks[joystick], button, false)
end

function Joystick:axis(joystick, axis, value)
	State.set(self.joysticks[joystick], axis, value)
end

function Joystick:hat(joystick, hat, direction)
	State.set(self.joysticks[joystick], hat, direction)
end

return Joystick
