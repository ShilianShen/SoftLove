---@class softlove.ui.System
---@field entry softlove.ui.Object
---@field order table[]
local System = {}

---@param object softlove.ui.Object
---@param order softlove.ui.Object[]
local function visit(object, order)
	table.insert(order, object)
	for _, child in ipairs(object.children) do
		visit(child, order)
	end
end

function System:init(entry)
	self.entry = entry
	self.order = {}
	visit(self.entry, self.order)
end

function System:draw()
	for _, object in ipairs(self.order) do
		object:background()
	end
	for i = #self.order, 1, -1 do
		local object = self.order[i]
		object:foreground()
	end
end

return System
