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

local siganls = {
	a = false,
	b = false,
	x = false,
	y = false,
	back = false,
	guide = false,
	start = false,
	leftstick = false,
	rightstick = false,
	leftshoulder = false,
	rightshoulder = false,
	dpup = false,
	dpdown = false,
	dpright = false,
	dpleft = false,
	leftx = 0,
	lefty = 0,
	rightx = 0,
	righty = 0,
	triggerleft = 0,
	triggerright = 0,
}

local function getInfo(joystick)
	return {
		name = joystick:getName(),
		id = joystick:getID(),
		guid = joystick:getGUID(),
		deviceInfo = joystick:getDeviceInfo(),
		axisCount = joystick:getAxisCount(),
		buttonCount = joystick:getButtonCount(),
		hatCount = joystick:getHatCount(),
	}
end

function Joystick:added(joystick)
	self.joysticks[joystick] = {}
	State.init(self.joysticks[joystick], {})
	for k, v in pairs(getInfo(joystick)) do
		self.joysticks[joystick][k] = v
	end
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

function Joystick:gamepadpressed(joystick, button)
	State.set(self.joysticks[joystick], button, true)
end

function Joystick:gamepadreleased(joystick, button)
	State.set(self.joysticks[joystick], button, false)
end

function Joystick:gamepadaxis(joystick, axis, value)
	State.set(self.joysticks[joystick], axis, value)
end

return Joystick
