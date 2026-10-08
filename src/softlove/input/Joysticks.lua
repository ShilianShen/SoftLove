local State = require("softlove.input.State")

local Joysticks = {}

---@alias softlove.input.JoystickKeys integer|love.GamepadButton|love.GamepadAxis

---@class softlove.input.Joystick: softlove.input.State<softlove.input.JoystickKeys>

---@class softlove.input.Joysticks
---@field joysticks table<integer, softlove.input.Joystick>
---@field get fun(self: softlove.input.Joysticks, id: integer, key: softlove.input.JoystickKeys): any, any

---@param self table
function Joysticks.init(self)
	self.joysticks = {}
	self.get = Joysticks.get
end

---@param self softlove.input.Joysticks
---@param id integer
---@param key softlove.input.JoystickKeys
---@return any, any
function Joysticks.get(self, id, key)
	if self.joysticks[id] == nil then
		return nil
	end
	return self.joysticks[id]:get(key)
end

---@param self softlove.input.Joysticks
function Joysticks.step(self)
	for _, state in pairs(self.joysticks) do
		State.step(state)
	end
end

---@param self softlove.input.Joysticks
---@param joystick love.Joystick
function Joysticks.added(self, joystick)
	local id = joystick:getID()
	local j = {}
	State.init(j)
	self.joysticks[id] = j
end

---@param self softlove.input.Joysticks
---@param joystick love.Joystick
function Joysticks.removed(self, joystick)
	local id = joystick:getID()
	self.joysticks[id] = nil
end

---@param self softlove.input.Joysticks
---@param joystick love.Joystick
---@param button softlove.input.JoystickKeys
function Joysticks.pressed(self, joystick, button)
	local id = joystick:getID()
	State.set(self.joysticks[id], button, true)
end

---@param self softlove.input.Joysticks
---@param joystick love.Joystick
---@param button softlove.input.JoystickKeys
function Joysticks.released(self, joystick, button)
	local id = joystick:getID()
	State.set(self.joysticks[id], button, false)
end

---@param self softlove.input.Joysticks
---@param joystick love.Joystick
---@param axis softlove.input.JoystickKeys
---@param value number
function Joysticks.axis(self, joystick, axis, value)
	local id = joystick:getID()
	State.set(self.joysticks[id], axis, value)
end

---@param self softlove.input.Joysticks
---@param joystick love.Joystick
---@param hat softlove.input.JoystickKeys
---@param direction love.JoystickHat
function Joysticks.hat(self, joystick, hat, direction)
	local id = joystick:getID()
	State.set(self.joysticks[id], hat, direction)
end

return Joysticks
