local ui = {}

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

---@type softdep.declaration.Api
ui.systemApiDraw = {
	func = drawSection,
	dirty = false,
	atag = "writable",
}

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
local function new(self, key, input)
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

local function section(self, t, entry)
	t._entry = entry
	t._order = {}
	visit(t._entry, t._order)
	t._draw = drawSection
end

local function newPatch(self, key, patch)
	self.patchs[key] = patch
end

function ui.getNode()
	---@type softdep.declaration.Node
	local node = {
		tasks = {
			init = {
				func = function(self)
					self.patchs = { Object = Object }
					self.new = new
					self.section = section
				end,
				atag = "writable",
				back = false,
			},
		},
		apis = {
			newPatch = { func = newPatch, atag = "writable", dirty = true },
		},
		atag = "readonly",
	}
	return node
end

return ui
