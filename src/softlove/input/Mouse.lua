local State = require("softlove.input.State")

---@class softlove.input.Mouse: softlove.input.State
local Mouse = {
	init = State.init,
	step = State.step,
}

---@param x number
---@param y number
---@param button integer
---@param istouch boolean
---@param presses boolean
function Mouse:pressed(x, y, button, istouch, presses)
	State.set(self, button, true)
end

---@param x number
---@param y number
---@param button integer
---@param istouch boolean
---@param presses boolean
function Mouse:released(x, y, button, istouch, presses)
	State.set(self, button, false)
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param istouch boolean
function Mouse:moved(x, y, dx, dy, istouch)
	State.set(self, "x", x)
	State.set(self, "y", y)
end

---@param focus boolean
function Mouse:focus(focus)
	State.set(self, "focus", focus)
end

return Mouse
