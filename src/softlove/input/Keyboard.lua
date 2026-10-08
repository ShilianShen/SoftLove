local State = require("softlove.input.State")
local Keyboard = {}

---@class softlove.input.KeyboardKeys: softlove.input.State<love.KeyConstant>

---@class softlove.input.KeyboardScancodes: softlove.input.State<love.Scancode>

---@class softlove.input.Keyboard
---@field keys softlove.input.KeyboardKeys
---@field scancodes softlove.input.KeyboardScancodes
---@field getKey function
---@field getScancode function

---@param self table
function Keyboard.init(self)
	self.keys = {}
	self.scancodes = {}
	State.init(self.keys)
	State.init(self.scancodes)
	self.getKey = Keyboard.getKey
	self.getScancode = Keyboard.getScancode
end

---@param self softlove.input.Keyboard
function Keyboard.step(self)
	State.step(self.keys)
	State.step(self.scancodes)
end

---@param self softlove.input.Keyboard
---@param key love.KeyConstant
---@param scancode love.Scancode
---@param isrepeat boolean
function Keyboard.pressed(self, key, scancode, isrepeat)
	State.set(self.keys, key, true)
	State.set(self.scancodes, scancode, true)
end

---@param self softlove.input.Keyboard
---@param key love.KeyConstant
---@param scancode love.Scancode
function Keyboard.released(self, key, scancode)
	State.set(self.keys, key, false)
	State.set(self.scancodes, scancode, false)
end

---@param self softlove.input.Keyboard
---@param key love.KeyConstant
---@return boolean
function Keyboard.getKey(self, key)
	return self.keys:get(key)
end

---@param self softlove.input.Keyboard
---@param scancode love.Scancode
---@return boolean
function Keyboard.getScancode(self, scancode)
	return self.scancodes:get(scancode)
end

return Keyboard
