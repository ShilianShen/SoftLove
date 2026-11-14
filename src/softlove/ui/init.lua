local ui = {
	Page = require("softlove.ui.Page"),
	WidgetType = require("softlove.ui.WidgetType"),
}

---@param name string
---@param patch softlove.ui.Patch|nil
---@return softlove.ui.Widget
local function newWidget(self, name, patch)
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
					self.widgetTypes = {}
					for name, widgetType in pairs(widgetTypes) do
						self.widgetTypes[name] = widgetType
					end
					self.newWidget = newWidget
				end,
				atag = "writable",
				back = false,
			},
		},
		apis = {
			register = {
				---@param name string
				---@param widgetType softlove.ui.WidgetType
				func = function(self, name, widgetType)
					self.widgetTypes[name] = widgetType
				end,
				atag = "writable",
				dirty = true,
			},
			unregister = {
				---@param name string
				func = function(self, name)
					self.widgetTypes[name] = nil
				end,
				atag = "writable",
				dirty = true,
			},
		},
		atag = "readonly",
	}
end

return ui
