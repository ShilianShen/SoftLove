local wheel = {}

local function init(self)
	self.dx = 0
	self.dy = 0
	self.move1 = false
	self.move2 = false
end

local function moved(self, dx, dy)
	self.dx = dx
	self.dy = dy
	self.move2 = true
end

local function dynamic(self)
	return self.move1 or self.move2
end

local function update(self)
	self.move1 = self.move2

	if not self.move2 then
		self.dx = 0
		self.dy = 0
	end

	self.move2 = false
end

function wheel.getNode()
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
			moved = {
				func = moved,
				atag = "writable",
			},
		},
	}
	return node
end

function wheel.getCallbacks(node)
	return {
		wheelmoved = node.apis.moved,
	}
end

return wheel
