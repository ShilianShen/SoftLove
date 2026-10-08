local State = require("softlove.input.State")

local Mouse = {
	init = State.init,
	step = State.step,
}

---@alias softlove.input.MouseKeys 1|2|3|"x"|"y"|"focus"

---@class softlove.input.MouseState
---@field x? number
---@field y? number
---@field focus? boolean
---@field [1] boolean|nil
---@field [2] boolean|nil
---@field [3] boolean|nil

---@class softlove.input.Mouse: softlove.input.State<softlove.input.MouseKeys>
---@field visit fun(self: softlove.input.Mouse): softlove.input.MouseState, softlove.input.MouseState

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
