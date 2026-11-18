local util = require("softlove.ui.util")
local object = require("softlove.ui.object")

---A widget type is a reusable template; deriving types and creating instances copy tables in the selected fields.
---Copying gives templates, parent and derived types, separate instances and reused children independent tables.
---Non-table values such as functions and userdata remain shared; external state captured by functions is not copied.
---@class softlove.ui.WidgetType: softlove.ui.Patch
---@operator call(softlove.ui.Patch?): softlove.ui.Widget
local WidgetType = {}

local typeMT = {
	__index = WidgetType,
	__call = function(self, patch)
		return self:newWidget(patch)
	end,
}

---Derive a type: patch takes precedence over parent; omitted fields are inherited, while false and 0 count as explicit values.
---Table fields are replaced as a whole except bounds, which merges coordinates; userData = { a = 1 } discards other inherited inputs.
---Deep-copy after merging without modifying patch or parent; cyclic tables raise an error. Instance defaults are not filled here.
---@param parent? softlove.ui.WidgetType
---@param patch? softlove.ui.Patch
---@return softlove.ui.WidgetType
function WidgetType.newWidgetType(parent, patch)
	local fields = util.patch(patch or {}, parent or {})
	fields.bounds = util.patch(patch and patch.bounds or {}, parent and parent.bounds or {})
	local widgetType = util.deepcopyDAGToTree(fields)
	return setmetatable(widgetType, typeMT)
end

---Create an instance: patch > type fields > object defaults; widgetType(patch) is equivalent.
---Select userData, loveData, children and other table fields as a whole, then deep-copy them; merge bounds by coordinate.
---userData and loveData each default to an empty table; changing instance tables does not modify the template or input patch.
---Deep copying splits repeated table references, so userData and loveData become independent even if initially assigned the same table.
---@param patch? softlove.ui.Patch
---@return softlove.ui.Widget
function WidgetType:newWidget(patch)
	local fields = util.patch(patch or {}, self, object)
	fields.bounds = util.patch(patch and patch.bounds or {}, self.bounds or {}, object.bounds)
	local widget = util.deepcopyDAGToTree(fields)
	return widget
end

return WidgetType
