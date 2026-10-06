local types = {}

---@class softlove.ui.Object
---@field x number
---@field y number
---@field w number
---@field h number
---@field layout fun(self: softlove.ui.Object, parent: softlove.ui.Object)
---@field foreground function
---@field background function
---@field children softlove.ui.Object[]

local function patch(...)
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

local mt = {
	__call = function(self, input)
		local result = patch(input, self, types.Object)
		result.children = result.children or {}
		return result
	end,
}

types.Object = setmetatable({
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	layout = function(self, parent)
		self.x = parent.x
		self.y = parent.y
		self.w = parent.w
		self.h = parent.h
	end,
	foreground = pass,
	background = pass,
}, mt)

types.Container = setmetatable({}, mt)

return types
