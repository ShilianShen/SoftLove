local ntags = require("softlove.ntags")
local keyboard = {}

function keyboard:init()
	self.buttons = {}
	self.isDown1 = {}
	self.isDown2 = {}
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = false
		self.isDown2[bt] = false
	end
end

function keyboard:update(key)
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
		self.isDown2[bt] = love.keyboard.isDown(bt)
	end
end

function keyboard:dynamic()
	for _, bt in pairs(self.buttons) do
		if self.isDown1[bt] ~= self.isDown2[bt] then
			return true
		end
	end
	return false
end

function keyboard.getNode()
	local node = {
		tasks = {
			init = {
				func = keyboard.init,
			},
			update = {
				func = keyboard.update,
				parents_c = { "init" },
				auto = keyboard.dynamic,
			},
		},
		apis = {
			update = {
				func = keyboard.newKey,
				ttag = "update",
				atag = "writable",
			},
		},
	}
	return node
end

function keyboard.setCallbacks(graph)
	love.keypressed = graph.nodes[ntags.devices.keyboard].apis.update
	love.keyreleased = graph.nodes[ntags.devices.keyboard].apis.update
end

function keyboard:newKey(key)
	if self.isDown2[key] == nil then
		table.insert(self.buttons, key)
	end
end

return keyboard
