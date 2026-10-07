---@class softlove.ui.Section
---@field _entry softlove.ui.Object
---@field _order table[]
---@field _draw function
local Section = {}

---@param object softlove.ui.Object
---@param order table[]
local function visit(object, order)
	table.insert(order, object)
	for _, child in ipairs(object._children) do
		visit(child, order)
	end
end

function Section:draw()
	for _, object in ipairs(self._order) do
		object:_background()
	end
	for i = #self._order, 1, -1 do
		local object = self._order[i]
		object:_foreground()
	end
end

---@param entry softlove.ui.Object
function Section:init(entry)
	self._entry = entry
	self._order = {}
	visit(self._entry, self._order)
	self._draw = Section.draw
end

return Section
