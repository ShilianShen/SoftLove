local util = require("softlove.ui.util")
local object = require("softlove.ui.object")

---@class softlove.ui.WidgetType
---@field x? number
---@field y? number
---@field w? number
---@field h? number
---@field z? number
---@field visible? boolean
---@field ["public"]? boolean
---@field active? boolean
---@field state? table<string, any>
---@field inside? fun(self: softlove.ui.Widget, x: number, y: number): boolean
---@field children? table<any, softlove.ui.Widget>
---@field _draw? fun(self: softlove.ui.Widget, theme: softlove.ui.Theme)
---@field _layout? fun(self: softlove.ui.Widget, parent: softlove.ui.Bounds)
---@field _update? fun(self: softlove.ui.Widget, params: table<string, table>)
---@field hooked? fun(self: softlove.ui.Widget): table
local WidgetType = {}

local typeMT = {
	__index = WidgetType,
	__call = function(self, patch)
		return self:newWidget(patch)
	end,
}

---@param parent softlove.ui.WidgetType|nil
---@param patch softlove.ui.Patch|nil
---@return softlove.ui.WidgetType
function WidgetType.newWidgetType(parent, patch)
	local widgetType = util.deepcopyDAGToTree(util.patch(patch or {}, parent or {}))
	return setmetatable(widgetType, typeMT)
end

---@param patch softlove.ui.Patch|nil
---@return softlove.ui.Widget
function WidgetType:newWidget(patch)
	local widget = util.deepcopyDAGToTree(util.patch(patch or {}, self, object))
	return widget
end

return WidgetType
