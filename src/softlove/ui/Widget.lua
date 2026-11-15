local util = require("softlove.ui.util")

---@class softlove.ui.Widget
---@field bounds softlove.ui.Bounds
---@field z number
---@field visible boolean
---@field ["public"] boolean
---@field active boolean
---@field userData table<string, any> User-provided inputs.
---@field loveData table<string, any> Data derived for rendering.
---@field setter table<string, fun(self: softlove.ui.Widget, ...): ...>
---@field children table<any, softlove.ui.Widget>
---@field _layout fun(self: softlove.ui.Widget, parent: softlove.ui.Bounds)
---@field _draw fun(self: softlove.ui.Widget, theme: softlove.ui.Theme)
---@field _update fun(self: softlove.ui.Widget, params: table<string, table>)
---@field _hook fun(self: softlove.ui.Widget, x: number, y: number): softlove.ui.Widget?, table?
---@field hook fun(self: softlove.ui.Widget, x: number, y: number): softlove.ui.Widget?, table?
---@field inside fun(self: softlove.ui.Widget, x: number, y: number): boolean
---@field hooked fun(self: softlove.ui.Widget): table
local Widget = {}

---@param parent softlove.ui.Bounds
function Widget:layout(parent)
	if not self.active then
		return
	end
	self:_layout(parent)
	for _, child in pairs(self.children) do
		child:layout(self.bounds)
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
function Widget:draw(theme)
	if not self.active then
		return
	end
	if self.visible then
		self:_draw(theme)
	end
	for _, child in ipairs(sort(self.children)) do
		child:draw(theme)
	end
end

---@param params table<string, table>
function Widget:update(params)
	self:_update(params)
	for _, child in ipairs(sort(self.children)) do
		child:update(params)
	end
end

---@param x number
---@param y number
---@return softlove.ui.Widget? widget
---@return table? hooked
function Widget:hook(x, y)
	if not self.active then
		return
	end
	local result, ownHooks = self:_hook(x, y)
	local hooked = {}
	for k, v in pairs(ownHooks or {}) do
		hooked[k] = v
	end
	for _, child in ipairs(sort(self.children)) do
		local childResult, childHooks = child:hook(x, y)
		result = childResult or result
		for k, v in pairs(childHooks or {}) do
			hooked[k] = v
		end
	end
	if result then
		return result, hooked
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
