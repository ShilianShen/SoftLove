local util = require("softlove.ui.util")
local WidgetType = require("softlove.ui.WidgetType")
local ui = {
	getPage = require("softlove.ui.getPage"),
}

---@class softlove.ui.Ui
---@field widgetTypes table<string, softlove.ui.WidgetType>
local Ui = {}

local function sortedKeys(values)
	local keys = {}
	for key in pairs(values) do
		keys[#keys + 1] = key
	end
	table.sort(keys)
	return keys
end

---@param widgets table<string, softlove.ui.WidgetTypeDeclaration>
---@return string[]
function Ui.sortWidgets(widgets)
	local dependencies = {}
	local function collect(declaration, parents, path)
		assert(type(declaration) == "table", "expected widget declaration at " .. path)
		local parent = declaration.type
		if parent ~= nil then
			assert(type(parent) == "string", "expected widget type name at " .. path)
			assert(widgets[parent] ~= nil, "unknown widget type: " .. parent .. " at " .. path)
			parents[parent] = true
		end
		if declaration.children ~= nil then
			assert(type(declaration.children) == "table", "expected children table at " .. path)
			for key, child in pairs(declaration.children) do
				collect(child, parents, path .. ".children[" .. tostring(key) .. "]")
			end
		end
	end
	for name, declaration in pairs(widgets) do
		assert(type(name) == "string", "expected string widget name")
		dependencies[name] = {}
		collect(declaration, dependencies[name], name)
	end

	local order, states, stack = {}, {}, {}
	local function visit(name)
		if states[name] == "done" then
			return
		end
		if states[name] == "visiting" then
			error("widget declaration dependency cycle: " .. table.concat(stack, " -> ") .. " -> " .. name)
		end
		states[name] = "visiting"
		stack[#stack + 1] = name
		for _, parent in ipairs(sortedKeys(dependencies[name])) do
			visit(parent)
		end
		stack[#stack] = nil
		states[name] = "done"
		order[#order + 1] = name
	end
	for _, name in ipairs(sortedKeys(widgets)) do
		visit(name)
	end
	return order
end

---@param declaration softlove.ui.WidgetTypeDeclaration
---@param widgetTypes table<string, softlove.ui.WidgetType>
---@return softlove.ui.WidgetType
function Ui.buildWidgetType(declaration, widgetTypes)
	local patch = {}
	for key, value in pairs(declaration) do
		if key ~= "type" and key ~= "children" then
			patch[key] = value
		end
	end
	if declaration.children ~= nil then
		patch.children = {}
		for key, child in pairs(declaration.children) do
			patch.children[key] = Ui.buildWidgetType(child, widgetTypes):newWidget()
		end
	end
	local parent = declaration.type and widgetTypes[declaration.type] or nil
	return WidgetType.newWidgetType(parent, patch)
end

---@param widgets table<string, softlove.ui.WidgetTypeDeclaration>
function Ui:init(widgets)
	assert(type(widgets) == "table", "expected widgets table")
	local declarations = util.deepcopyDAGToTree(widgets)
	local order = Ui.sortWidgets(declarations)
	local widgetTypes = {}
	for _, name in ipairs(order) do
		widgetTypes[name] = Ui.buildWidgetType(declarations[name], widgetTypes)
	end
	self.widgetTypes = widgetTypes
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

---@param widgets table<string, softlove.ui.WidgetTypeDeclaration>
---@return softdep.declaration.Node
function ui.getNode(widgets)
	return {
		tasks = {
			init = {
				func = function(self)
					Ui.init(self, widgets)
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
