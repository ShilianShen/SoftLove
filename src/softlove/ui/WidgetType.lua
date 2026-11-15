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
	local fields = util.patch(patch or {}, parent or {})
	fields.border = util.patch(patch and patch.border or {}, parent and parent.border or {})
	local widgetType = util.deepcopyDAGToTree(fields)
	return setmetatable(widgetType, typeMT)
end

---@param patch softlove.ui.Patch|nil
---@return softlove.ui.Widget
function WidgetType:newWidget(patch)
	local fields = util.patch(patch or {}, self, object)
	fields.border = util.patch(patch and patch.border or {}, self.border or {}, object.border)
	local widget = util.deepcopyDAGToTree(fields)
	return widget
end

return WidgetType
