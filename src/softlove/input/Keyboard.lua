local State = require("softlove.input.State")
local Keyboard = {}

---@class softlove.input.KeyboardKeysState
---@field [love.KeyConstant] boolean|nil

---@class softlove.input.KeyboardKeys: softlove.input.State<softlove.input.KeyboardKeysState>
---@field visit fun(self: softlove.input.KeyboardKeys): softlove.input.KeyboardKeysState, softlove.input.KeyboardKeysState

---@class softlove.input.KeyboardScancodesState
---@field [love.Scancode] boolean|nil

---@class softlove.input.KeyboardScancodes: softlove.input.State<softlove.input.KeyboardScancodesState>
---@field visit fun(self: softlove.input.KeyboardScancodes): softlove.input.KeyboardScancodesState, softlove.input.KeyboardScancodesState

---@class softlove.input.Keyboard
---@field keys softlove.input.KeyboardKeys
---@field scancodes softlove.input.KeyboardScancodes
---@field visit function

---@param self table
function Keyboard.init(self)
	self.keys = {}
	self.scancodes = {}
	State.init(self.keys)
	State.init(self.scancodes)
	self.visit = Keyboard.visit
end

---@param self softlove.input.Keyboard
function Keyboard.step(self)
	State.step(self.keys)
	State.step(self.scancodes)
end

---@param self softlove.input.Keyboard
---@param name "keys"|"scancodes"
function Keyboard.visit(self, name)
	return State.visit(self[name])
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
