local util = require("softlove.ui.util")
local object = require("softlove.ui.object")

---@class softlove.ui.WidgetType: softlove.ui.Patch
---@operator call(softlove.ui.Patch?): softlove.ui.Widget
local WidgetType = {}

local typeMT = {
	__index = WidgetType,
	__call = function(self, patch)
		return self:newWidget(patch)
	end,
}

---@param parent? softlove.ui.WidgetType
---@param patch? softlove.ui.Patch
---@return softlove.ui.WidgetType
function WidgetType.newWidgetType(parent, patch)
	local fields = util.patch(patch or {}, parent or {})
	fields.bounds = util.patch(patch and patch.bounds or {}, parent and parent.bounds or {})
	local widgetType = util.deepcopyDAGToTree(fields)
	return setmetatable(widgetType, typeMT)
end

---@param patch? softlove.ui.Patch
---@return softlove.ui.Widget
function WidgetType:newWidget(patch)
	local fields = util.patch(patch or {}, self, object)
	fields.bounds = util.patch(patch and patch.bounds or {}, self.bounds or {}, object.bounds)
	local widget = util.deepcopyDAGToTree(fields)
	return widget
end

return WidgetType
