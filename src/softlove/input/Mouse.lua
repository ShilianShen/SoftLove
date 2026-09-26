local State = require("softlove.input.State")
local Mouse = {}

function Mouse:init()
	State.init(self)
end

function Mouse:pressed(x, y, button, istouch, presses)
	State.set(self, button, true)
end

function Mouse:released(x, y, button, istouch, presses)
	State.set(self, button, false)
end

function Mouse:moved(x, y, dx, dy, istouch)
	State.set(self, "x", x)
	State.set(self, "y", y)
end

function Mouse:focus(focus)
	State.set(self, "focus", focus)
end

return Mouse
