local keyboard = {}

local function init(self)
	self.buttons = {}
	self.isDown1 = {}
	self.isDown2 = {}
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = false
		self.isDown2[bt] = false
	end
end

local function update(self, key)
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
		self.isDown2[bt] = love.keyboard.isDown(bt)
	end
end

local function dynamic(self)
	for _, bt in pairs(self.buttons) do
		if self.isDown1[bt] ~= self.isDown2[bt] then
			return true
		end
	end
	return false
end

local function newKey(self, key)
	if self.isDown2[key] == nil then
		table.insert(self.buttons, key)
	end
end

function keyboard.getNode()
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
				func = newKey,
				ttag = "update",
				atag = "writable",
			},
		},
	}
	return node
end

function keyboard.setCallbacks(node)
	love.keypressed = node.apis.update
	love.keyreleased = node.apis.update
end

return keyboard
