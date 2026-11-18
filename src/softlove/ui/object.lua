local util = require("softlove.ui.util")
local Widget = require("softlove.ui.Widget")

---Instance defaults; WidgetType:newWidget deep-copies selected tables, so instances do not share these empty data tables.
---Keep application inputs in userData and derived display data in loveData; default callbacks do not synchronize them.
---@type softlove.ui.Widget
return {
	bounds = { x = 0, y = 0, w = 0, h = 0 },
	depth = 0,
	visible = true,
	active = true,
	userData = {},
	loveData = {},
	inside = function()
		return true
	end,
	children = {},
	order = {},
	-- Copy the parent's coordinates individually rather than aliasing its bounds table.
	_layout = function(self, bounds)
		self.bounds.x = bounds.x
		self.bounds.y = bounds.y
		self.bounds.w = bounds.w
		self.bounds.h = bounds.h
	end,
	_draw = util.pass,
	_update = util.pass,
	_hook = function()
		return {}
	end,
	layout = Widget.layout,
	draw = Widget.draw,
	update = Widget.update,
	hook = Widget.hook,
	sort = Widget.sort,
}
