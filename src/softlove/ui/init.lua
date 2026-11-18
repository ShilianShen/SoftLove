local util = require("softlove.ui.util")
local WidgetType = require("softlove.ui.WidgetType")
local ui = {
	Page = require("softlove.ui.Page"),
}

---@class softlove.ui.Ui
---@field widgetTypes table<string, softlove.ui.WidgetType>
local Ui = {}

-- Keep in sync with WidgetTypeDeclaration and its inherited Patch fields; keys within userData/loveData are unrestricted.
local declarationFields = {
	type = true,
	bounds = true,
	depth = true,
	visible = true,
	active = true,
	userData = true,
	loveData = true,
	inside = true,
	children = true,
	_draw = true,
	_layout = true,
	_update = true,
	_hook = true,
	layout = true,
	sort = true,
	draw = true,
	update = true,
	hook = true,
}

local function sortedKeys(values)
	local keys = {}
	for key in pairs(values) do
		keys[#keys + 1] = key
	end
	table.sort(keys)
	return keys
end

---Validate all declarations and order dependencies from type and nested type references so dependencies are built before their users.
---@param widgets table<string, softlove.ui.WidgetTypeDeclaration>
function Ui.sortWidgets(widgets)
	local dependencies = {}
	local function collect(declaration, parents, path)
		assert(type(declaration) == "table", "expected widget declaration at " .. path)
		for key in pairs(declaration) do
			assert(declarationFields[key], "unknown widget declaration property: " .. tostring(key) .. " at " .. path)
		end
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

---Strip the declaration-only type field, build child declarations into Widget instances, then derive the current type.
---@param declaration softlove.ui.WidgetTypeDeclaration
---@param widgetTypes table<string, softlove.ui.WidgetType>
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

---Copy declarations during initialization; replace the existing registry only after the entire new registry builds successfully.
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

---Register an existing type by reference without copying; newWidget copies its table fields when creating instances later.
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
---@param patch? softlove.ui.Patch
function Ui:newWidget(name, patch)
	local widgetType = assert(self.widgetTypes[name], "unknown widget type: " .. tostring(name))
	return widgetType:newWidget(patch)
end

---Declare a registry of reusable widget types; validation and construction run in the returned SoftDep node's init task.
---Declarations, types and instances own copied data tables; changing the original declarations later does not update the built registry.
---Application code supplies state through instance userData; _update stores derived display results in the widget's loveData.
---For example, a minimal numeric widget declaration (_update and _draw are plain functions):
---```lua
---ui.Widgets({
---    counter = {
---        userData = {
---            value = 0,
---            setValue = function(self, value) self.value = value end,
---        },
---        _update = function(userData, loveData, params, children)
---            loveData.text = tostring(userData.value)
---        end,
---        _draw = function(userData, loveData, bounds, theme)
---            love.graphics.print(loveData.text or "", bounds.x, bounds.y)
---        end,
---    },
---})
---```
---After creating an instance, call widget.userData:setValue(42); the next update recomputes loveData.text.
---@param widgets table<string, softlove.ui.WidgetTypeDeclaration>
---@return softdep.declaration.Node
function ui.Widgets(widgets)
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
