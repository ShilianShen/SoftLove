local ui = {}
local Ui = {}

---@class softlove.ui.Object
---@field _x number
---@field _y number
---@field _w number
---@field _h number
---@field _layout fun(self: softlove.ui.Object, parent: softlove.ui.Object)
---@field _foreground function
---@field _background function
---@field _children softlove.ui.Object[]

---@class softlove.ui.System
---@field entry softlove.ui.Object
---@field order table[]

local function drawSection(self)
	for _, object in ipairs(self._order) do
		object:_background()
	end
	for i = #self._order, 1, -1 do
		local object = self._order[i]
		object:_foreground()
	end
end

local function applyPatch(...)
	local args = { ... }
	local result = {}
	for _, arg in ipairs(args) do
		for k, v in pairs(arg) do
			if result[k] == nil then
				result[k] = v
			end
		end
	end
	return result
end

local function pass() end

local Object = {
	_x = 0,
	_y = 0,
	_w = 0,
	_h = 0,
	_layout = function(self, parent)
		self.x = parent.x
		self.y = parent.y
		self.w = parent.w
		self.h = parent.h
	end,
	_foreground = pass,
	_background = pass,
}

---@param key string
---@param input table
---@return table
function Ui:new(key, input)
	local patch = self.patchs[key]
	local result = applyPatch(input, patch, self.patchs.Object)
	result.children = result.children or {}
	return result
end

local function visit(object, order)
	table.insert(order, object)
	for _, child in ipairs(object.children) do
		visit(child, order)
	end
end

function Ui:section(t, entry)
	t._entry = entry
	t._order = {}
	visit(t._entry, t._order)
	t._draw = drawSection
end

function Ui:newPatch(key, patch)
	self.patchs[key] = patch
end

function Ui:init()
	self.patchs = { Object = Object }
	self.new = Ui.new
	self.section = Ui.section
end

function ui.getNode()
	---@type softdep.declaration.Node
	local node = {
		tasks = {
			init = {
				func = Ui.init,
				atag = "writable",
				back = false,
			},
		},
		apis = {
			newPatch = { func = Ui.newPatch, atag = "writable", dirty = true },
		},
		atag = "readonly",
	}
	return node
end

return ui
