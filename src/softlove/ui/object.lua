local util = require("softlove.ui.util")
local Widget = require("softlove.ui.Widget")

---@type softlove.ui.Widget
return {
	bounds = { x = 0, y = 0, w = 0, h = 0 },
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
	order = {},
	_layout = function(self, parent)
		self.bounds.x = parent.x
		self.bounds.y = parent.y
		self.bounds.w = parent.w
		self.bounds.h = parent.h
	end,
	_draw = util.pass,
	_update = util.pass,
	_hook = function(self, x, y)
		if
			self.visible
			and self.bounds.x < x
			and x < self.bounds.x + self.bounds.w
			and self.bounds.y < y
			and y < self.bounds.y + self.bounds.h
			and self:inside(x, y)
		then
			return self, self:hooked()
		end
	end,
	layout = Widget.layout,
	draw = Widget.draw,
	update = Widget.update,
	hook = Widget.hook,
	sort = Widget.sort,
	hooked = function()
		return {}
	end,
}
