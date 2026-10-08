local State = require("softlove.input.State")
local Keyboard = {}

---@class softlove.input.KeyboardKeysState
---@field [love.KeyConstant] boolean|nil

---@class softlove.input.KeyboardKeys: softlove.input.State<love.KeyConstant>
---@field visit fun(self: softlove.input.KeyboardKeys): softlove.input.KeyboardKeysState, softlove.input.KeyboardKeysState

---@class softlove.input.KeyboardScancodesState
---@field [love.Scancode] boolean|nil

---@class softlove.input.KeyboardScancodes: softlove.input.State<love.Scancode>
---@field visit fun(self: softlove.input.KeyboardScancodes): softlove.input.KeyboardScancodesState, softlove.input.KeyboardScancodesState

---@class softlove.input.Keyboard
---@field keys softlove.input.KeyboardKeys
---@field scancodes softlove.input.KeyboardScancodes
---@field visitKeys fun(self: softlove.input.Keyboard): softlove.input.KeyboardKeysState, softlove.input.KeyboardKeysState
---@field visitScancodes fun(self: softlove.input.Keyboard): softlove.input.KeyboardScancodesState, softlove.input.KeyboardScancodesState

---@param self table
function Keyboard.init(self)
	self.keys = {}
	self.scancodes = {}
	State.init(self.keys)
	State.init(self.scancodes)
	self.visitKeys = Keyboard.visitKeys
	self.visitScancodes = Keyboard.visitScancodes
end

---@param self softlove.input.Keyboard
function Keyboard.step(self)
	State.step(self.keys)
	State.step(self.scancodes)
end

---@param self softlove.input.Keyboard
---@return softlove.input.KeyboardKeysState, softlove.input.KeyboardKeysState
function Keyboard.visitKeys(self)
	return self.keys:visit()
end

---@param self softlove.input.Keyboard
---@return softlove.input.KeyboardScancodesState, softlove.input.KeyboardScancodesState
function Keyboard.visitScancodes(self)
	return self.scancodes:visit()
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

return Keyboard
