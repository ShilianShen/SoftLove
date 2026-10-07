---@class softlove.ui.Section
---@field entry softlove.ui.Object
---@field order table[]
---@field draw function
local Section = {}

---@param object softlove.ui.Object
---@param order table[]
local function visit(object, order)
	table.insert(order, object)
	for _, child in ipairs(object.children) do
		visit(child, order)
	end
end

function Section:draw()
	for _, object in ipairs(self.order) do
		object:background()
	end
	for i = #self.order, 1, -1 do
		local object = self.order[i]
		object:foreground()
	end
end

---@param entry softlove.ui.Object
function Section:init(entry)
	self.entry = entry
	self.order = {}
	visit(self.entry, self.order)
	self.draw = Section.draw
end

function Section:update(params)
	self.entry:update(nil, params)
	for _, object in ipairs(self.order) do
		for _, child in ipairs(object.children) do
			child:update(object, params)
		end
	end
end

function Section.getNode(getEnrty, parents_d)
	---@type softdep.declaration.Node
	local node = {
		tasks = {
			init = {
				func = function(self, params)
					Section.init(self, getEnrty(params.ui))
				end,
				atag = "writable",
				back = false,
				parents_d = { ui = "ui" },
			},
			update = {
				func = Section.update,
				atag = "writable",
				back = false,
				parents_d = parents_d,
				parents_c = { "init" },
			},
		},
		apis = {
			draw = {
				func = Section.draw,
				atag = "writable",
				dirty = false,
			},
		},
		atag = "readonly",
	}
	return node
end

return Section
