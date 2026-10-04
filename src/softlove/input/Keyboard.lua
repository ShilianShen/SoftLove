local State = require("softlove.input.State")
local Keyboard = {}

function Keyboard:init()
	self.keys = {}
	self.scancodes = {}
	State.init(self.keys)
	State.init(self.scancodes)
end

function Keyboard:step()
	State.step(self.keys)
	State.step(self.scancodes)
end

---@param name "keys"|"scancodes"
function Keyboard:visit(name)
	return State.visit(self[name])
end

function Keyboard:pressed(key, scancode, isrepeat)
	State.set(self.keys, key, true)
	State.set(self.scancodes, scancode, true)
end

function Keyboard:released(key, scancode)
	State.set(self.keys, key, false)
	State.set(self.scancodes, scancode, false)
end

return Keyboard
