local Mouse = {}
local State = require("softlove.input.State")
local signals = { [1] = false, [2] = false, [3] = false, x = 0, y = 0, focus = false }

function Mouse:init()
	State.init(self, signals)
end

function Mouse:pressed(x, y, button, istouch, presses)
	self.s3[button] = true
end

function Mouse:released(x, y, button, istouch, presses)
	self.s3[button] = false
end

function Mouse:moved(x, y, dx, dy, istouch)
	self.s3.x = x
	self.s3.y = y
end

function Mouse:focus(focus)
	self.s3.focus = focus
end

return Mouse
