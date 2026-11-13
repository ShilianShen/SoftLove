local util = require("softlove.ui.util")
local Widget = require("softlove.ui.Widget")

---@type softlove.ui.Widget
return {
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	z = 0,
	visible = true,
	public = false,
	active = true,
	state = {},
	inside = function()
		return true
	end,
	children = {},
	_layout = function(self, parent)
		self.x = parent.x
		self.y = parent.y
		self.w = parent.w
		self.h = parent.h
	end,
	_draw = util.pass,
	_update = util.pass,
	_focus = function(self, x, y)
		if
			self.visible
			and self.x < x
			and x < self.x + self.w
			and self.y < y
			and y < self.y + self.h
			and self:inside(x, y)
		then
			return self, self:hooked()
		end
	end,
	layout = Widget.layout,
	draw = Widget.draw,
	update = Widget.update,
	focus = Widget.focus,
	hooked = function()
		return {}
	end,
}
