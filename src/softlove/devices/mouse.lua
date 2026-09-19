local mouse = {}

local function init(self)
	self.buttons = { 1, 2, 3 }
	self.x1, self.y1 = 0, 0
	self.x2, self.y2 = 0, 0
	self.isDown1 = {}
	self.isDown2 = {}
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = false
		self.isDown2[bt] = false
	end
end

local function update(self)
	self.x1, self.y1 = self.x2, self.y2
	self.x2, self.y2 = love.mouse.getPosition()
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
		self.isDown2[bt] = love.mouse.isDown(bt)
	end
end

local function dynamic(self)
	for _, bt in pairs(self.buttons) do
		if self.isDown1[bt] ~= self.isDown2[bt] then
			return true
		end
	end
	if self.x1 ~= self.x2 or self.y1 ~= self.y2 then
		return true
	end
	return false
end

function mouse.getNode()
	local node = {
		tasks = {
			init = {
				func = init,
			},
			update = {
				func = update,
				parents_c = { "init" },
				auto = dynamic,
			},
		},
		apis = {
			update = {
				ttag = "update",
			},
		},
	}
	return node
end

function mouse.setCallbacks(node)
	love.mousemoved = node.apis.update
	love.mousepressed = node.apis.update
	love.mousereleased = node.apis.update
end

return mouse
