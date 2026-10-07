---@class softlove.ui.Patch
---@field _x number|nil
---@field _y number|nil
---@field _w number|nil
---@field _h number|nil
---@field _update fun(self: softlove.ui.Object, parent: softlove.ui.Object)|nil
---@field _foreground function|nil
---@field _background function|nil
---@field _children softlove.ui.Object[]|nil
---@field _theme table|nil

---@class softlove.ui.Object
---@field _x number
---@field _y number
---@field _w number
---@field _h number
---@field _update fun(self: softlove.ui.Object, parent: softlove.ui.Object)
---@field _foreground function
---@field _background function
---@field _children softlove.ui.Object[]
---@field _theme table

---@class softlove.ui.Ui
---@field patchs table<string, softlove.ui.Patch>
---@field new function
local Ui = {}

local function pass() end

local function deepcopy(orig, seen)
	if type(orig) ~= "table" then
		return orig
	end

	seen = seen or {}
	if seen[orig] then
		return seen[orig]
	end

	local copy = {}
	seen[orig] = copy

	for k, v in pairs(orig) do
		copy[deepcopy(k, seen)] = deepcopy(v, seen)
	end

	return copy
end

---@type softlove.ui.Patch
local Object = {
	_x = 0,
	_y = 0,
	_w = 0,
	_h = 0,
	_update = function(self, parent)
		self._x = parent._x
		self._y = parent._y
		self._w = parent._w
		self._h = parent._h
		self._theme = deepcopy(parent._theme)
	end,
	_foreground = pass,
	_background = pass,
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

---@param key string
---@param patch softlove.ui.Patch
function Ui:newPatch(key, patch)
	for k, v in pairs(patch) do
		if type(v) == "table" then
			patch[k] = nil
		end
	end
	self.patchs[key] = patch
end

---@param key string
---@param input softlove.ui.Patch
---@return softlove.ui.Object
function Ui:new(key, input)
	local patch = self.patchs[key] or {}
	local result = applyPatch(input, patch, Object)
	result._children = result._children or {}
	result._theme = result._theme or {}
	return result
end

function Ui:init()
	self.patchs = { Object = Object }
	self.new = Ui.new
end

return Ui
