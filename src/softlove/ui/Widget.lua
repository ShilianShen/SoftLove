local util = require("softlove.ui.util")

---@class softlove.ui.Widget: softlove.ui.Bounds
---@field z number
---@field visible boolean
---@field ["public"] boolean
---@field active boolean
---@field state table<string, any>
---@field children table<any, softlove.ui.Widget>
---@field _layout fun(self: softlove.ui.Widget, parent: softlove.ui.Bounds)
---@field _draw fun(self: softlove.ui.Widget, theme: softlove.ui.Theme)
---@field _update fun(self: softlove.ui.Widget, params: table<string, table>)
---@field inside fun(self: softlove.ui.Widget, x: number, y: number): boolean
---@field hooked fun(self: softlove.ui.Widget): table
local Widget = {}

---@param parent softlove.ui.Bounds
---@param options? {debug: boolean, noise: number, target?: softlove.ui.Widget}
function Widget:layout(parent, options)
	if not self.active then
		return
	end
	self:_layout(parent)
	for _, child in pairs(self.children) do
		if child.active then
			if options and options.debug then
				local dx = math.random(-options.noise, options.noise)
				local dy = math.random(-options.noise, options.noise)
				local a = {
					x = self.x + dx,
					y = self.y + dy,
					w = self.w,
					h = self.h,
				}
				child:layout(a, options)
			else
				child:layout(self, options)
			end
		end
	end
end

local function compare(widget1, widget2)
	return widget1.z < widget2.z
end

local function sort(children)
	local order = {}
	for _, child in pairs(children) do
		order[#order + 1] = child
	end
	table.sort(order, compare)
	return order
end

---@param theme softlove.ui.Theme
---@param options? {debug: boolean, noise: number, target?: softlove.ui.Widget}
function Widget:draw(theme, options)
	if not self.active then
		return
	end
	if self.visible then
		if options and options.debug and self == options.target then
			love.graphics.setColor(math.random(), math.random(), math.random(), math.random() * 0.1)
			love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		end
		self:_draw(theme)
		if options and options.debug and self == options.target then
			love.graphics.setColor(math.random(), math.random(), math.random(), math.random())
			love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
		end
	end
	for _, child in ipairs(sort(self.children)) do
		child:draw(theme, options)
	end
end

---@param params table<string, table>
function Widget:update(params)
	for _, child in ipairs(sort(self.children)) do
		child:_update(params)
		child:update(params)
	end
end

---@param widget softlove.ui.Widget
---@param x number
---@param y number
local function inWidget(widget, x, y)
	return widget.x < x and x < widget.x + widget.w and widget.y < y and y < widget.y + widget.h
end

---@param widget softlove.ui.Widget
---@param x number
---@param y number
---@param hooked table
local function focusWidget(widget, x, y, hooked)
	if not widget.active then
		return
	end
	local result = nil
	if widget.visible and inWidget(widget, x, y) and widget:inside(x, y) then
		for k, v in pairs(widget:hooked()) do
			hooked[k] = v
		end
		result = widget
	end
	for _, child in ipairs(sort(widget.children)) do
		result = focusWidget(child, x, y, hooked) or result
	end
	return result
end

---@param x number
---@param y number
---@return softlove.ui.Widget? widget
---@return table? hooked
function Widget:focus(x, y)
	local hooked = {}
	local widget = focusWidget(self, x, y, hooked)
	if widget == nil then
		return
	else
		return widget, hooked
	end
end

---@param root softlove.ui.Widget
---@param ... any
---@return table?
function Widget.get(root, ...)
	local args = { ... }
	local widget = root
	for _, arg in ipairs(args) do
		widget = widget.children[arg]
		if widget == nil then
			return
		end
	end
	if widget.public then
		return util.const(widget)
	end
end

return Widget
