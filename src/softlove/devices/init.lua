local mouse = require("softlove.devices.mouse")
local keyboard = require("softlove.devices.keyboard")
local joystick = require("softlove.devices.joystick")
local wheel = require("softlove.devices.wheel")
local ntags = require("softlove.ntags")

local devices = {}

function devices.getNodes()
	local nodes = {}

	nodes[ntags.devices.mouse] = {
		tasks = {
			init = {
				func = mouse.init,
			},
			update = {
				func = mouse.update,
				parents_c = { "init" },
				auto = mouse.dynamic,
			},
		},
		apis = {
			update = {
				ttag = "update",
			},
		},
	}

	nodes[ntags.devices.keyboard] = {
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
			},
		},
	}

	nodes[ntags.devices.joystick] = {}
	nodes[ntags.devices.wheel] = {}
	return nodes
end

function devices.setCallbacks(graph)
	function love.mousemoved(...)
		graph.nodes[ntags.devices.mouse].apis.update()
	end

	function love.mousepressed(...)
		graph.nodes[ntags.devices.mouse].apis.update()
	end

	function love.mousereleased(...)
		graph.nodes[ntags.devices.mouse].apis.update()
	end

	function love.keypressed(key)
		graph.nodes[ntags.devices.keyboard].apis.update(key)
	end

	function love.keyreleased(key)
		graph.nodes[ntags.devices.keyboard].apis.update(key)
	end
end

return devices
