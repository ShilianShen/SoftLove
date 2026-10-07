local Section = {}

local function visit(object, order)
	table.insert(order, object)
	for _, child in ipairs(object.children) do
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

function Section:init(entry)
	self._entry = entry
	self._order = {}
	visit(self._entry, self._order)
	self._draw = Section.draw
end

return Section
