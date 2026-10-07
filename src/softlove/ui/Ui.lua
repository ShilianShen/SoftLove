local Ui = {}

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

function Ui:newPatch(key, patch)
	self.patchs[key] = patch
end

---@param key string
---@param input table
---@return table
function Ui:new(key, input)
	local patch = self.patchs[key]
	local result = applyPatch(input, patch, Object)
	result.children = result.children or {}
	return result
end

function Ui:init()
	self.patchs = { Object = Object }
	self.new = Ui.new
end

return Ui
