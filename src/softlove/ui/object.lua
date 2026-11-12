local layout = require("src.ui.layout")
local util = require("src.util")
local Widget = require("src.ui.Widget")

---@type ui.Widget
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
	_layout = layout.copy,
	_draw = util.pass,
	_update = util.pass,
	layout = Widget.layout,
	draw = Widget.draw,
	update = Widget.update,
	hooked = function()
		return {}
	end,
}
