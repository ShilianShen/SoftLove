local ui = {
	Page = require("softlove.ui.Page"),
	WidgetType = require("softlove.ui.WidgetType"),
}

local Ui = {}

---@param widgetTypes table<string, softlove.ui.WidgetType>
function Ui:init(widgetTypes)
	self.widgetTypes = {}
	for name, widgetType in pairs(widgetTypes) do
		Ui.register(self, name, widgetType)
	end
	self.newWidget = Ui.newWidget
end

---@param name string
---@param widgetType softlove.ui.WidgetType
function Ui:register(name, widgetType)
	self.widgetTypes[name] = widgetType
end

---@param name string
function Ui:unregister(name)
	self.widgetTypes[name] = nil
end

---@param name string
---@param patch softlove.ui.Patch|nil
---@return softlove.ui.Widget
function Ui:newWidget(name, patch)
	local widgetType = assert(self.widgetTypes[name], "unknown widget type: " .. tostring(name))
	return widgetType:newWidget(patch)
end

---@param widgetTypes table<string, softlove.ui.WidgetType>
---@return softdep.declaration.Node
function ui.getNode(widgetTypes)
	return {
		tasks = {
			init = {
				func = function(self)
					Ui.init(self, widgetTypes)
				end,
				atag = "writable",
				back = false,
			},
		},
		apis = {
			register = {
				func = Ui.register,
				atag = "writable",
				dirty = true,
			},
			unregister = {
				func = Ui.unregister,
				atag = "writable",
				dirty = true,
			},
		},
		atag = "readonly",
	}
end

return ui
