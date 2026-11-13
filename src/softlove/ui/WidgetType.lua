local util = require("softlove.ui.util")
local object = require("softlove.ui.object")

---@class softlove.ui.WidgetType: softlove.ui.Patch
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
