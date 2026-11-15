local util = require("softlove.ui.util")
local Widget = require("softlove.ui.Widget")

---@type softlove.ui.Widget
return {
	border = { x = 0, y = 0, w = 0, h = 0 },
	z = 0,
	visible = true,
	public = false,
	active = true,
	userData = {},
	loveData = {},
	setter = {},
	inside = function()
		return true
	end,
	children = {},
	_layout = function(self, parent)
		self.border.x = parent.x
		self.border.y = parent.y
		self.border.w = parent.w
		self.border.h = parent.h
	end,
	_draw = util.pass,
	_update = util.pass,
	_hook = function(self, x, y)
		if
			self.visible
			and self.border.x < x
			and x < self.border.x + self.border.w
			and self.border.y < y
			and y < self.border.y + self.border.h
			and self:inside(x, y)
		then
			return self, self:hooked()
		end
	end,
	layout = Widget.layout,
	draw = Widget.draw,
	update = Widget.update,
	hook = Widget.hook,
	hooked = function()
		return {}
	end,
}
