local State = require("softlove.input.State")
local Keyboard = {}

function Keyboard:init()
	self.keys = {}
	self.scancodes = {}
	State.init(self.keys)
	State.init(self.scancodes)
end

function Keyboard:update()
	State.update(self.keys)
	State.update(self.scancodes)
end

function Keyboard:isDynamic()
	return State.isDynamic(self.keys) or State.isDynamic(self.scancodes)
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
