local State = require("softlove.input.State")

local Mouse = {
	init = State.init,
	step = State.step,
}

---@alias softlove.input.MouseKeys 1|2|3|"x"|"y"|"focus"

---@class softlove.input.Mouse: softlove.input.State
---@field s1 table<softlove.input.MouseKeys, any>
---@field s2 table<softlove.input.MouseKeys, any>
---@field s1const table<softlove.input.MouseKeys, any>
---@field s2const table<softlove.input.MouseKeys, any>

---@param self softlove.input.Mouse
---@param x number
---@param y number
---@param button softlove.input.MouseKeys
---@param istouch boolean
---@param presses boolean
function Mouse.pressed(self, x, y, button, istouch, presses)
	State.set(self, button, true)
end

---@param self softlove.input.Mouse
---@param x number
---@param y number
---@param button softlove.input.MouseKeys
---@param istouch boolean
---@param presses boolean
function Mouse.released(self, x, y, button, istouch, presses)
	State.set(self, button, false)
end

---@param self softlove.input.Mouse
---@param x number
---@param y number
---@param dx number
---@param dy number
---@param istouch boolean
function Mouse.moved(self, x, y, dx, dy, istouch)
	State.set(self, "x", x)
	State.set(self, "y", y)
end

---@param self softlove.input.Mouse
---@param focus boolean
function Mouse.focus(self, focus)
	State.set(self, "focus", focus)
end

return Mouse
