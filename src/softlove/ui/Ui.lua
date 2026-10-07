---@class softlove.ui.Patch
---@field x number|nil
---@field y number|nil
---@field w number|nil
---@field h number|nil
---@field update fun(self: softlove.ui.Object, parent: softlove.ui.Object|nil, params: table<string, table>)|nil
---@field foreground function|nil
---@field background function|nil
---@field children softlove.ui.Object[]|nil
---@field theme table|nil

---@class softlove.ui.Object
---@field x number
---@field y number
---@field w number
---@field h number
---@field update fun(self: softlove.ui.Object, parent: softlove.ui.Object|nil, params: table<string, table>)
---@field foreground function
---@field background function
---@field children softlove.ui.Object[]
---@field theme table

---@class softlove.ui.Ui
---@field patchs table<string, softlove.ui.Patch>
---@field new function
local Ui = {}

local function pass() end

---@type softlove.ui.Patch
local Object = {
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	update = pass,
	foreground = pass,
	background = pass,
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
	result.children = result.children or {}
	result.theme = result.theme or {}
	return result
end

function Ui:init()
	self.patchs = { Object = Object }
	self.new = Ui.new
end

return Ui
