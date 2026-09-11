local mouse = require("softlove.devices.mouse")
local keyboard = require("softlove.devices.keyboard")
local joystick = require("softlove.devices.joystick")

local devices = {}

local defaultNtags = {
	mouse = "mouse",
	keyboard = "keyboard",
	joystick = "joystick",
}

function devices.getNodes(ntags)
	local nodes = {}
	ntags = ntags or defaultNtags
	for k, v in pairs(defaultNtags) do
		ntags[k] = ntags[k] or v
	end
	devices.ntags = ntags

	nodes[ntags.mouse] = {
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

	nodes[ntags.keyboard] = {
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

	nodes[ntags.joystick] = {}

	return nodes
end

function devices.setCallbacks(graph)
	function love.mousemoved(...)
		graph.nodes[devices.ntags.mouse].apis.update()
	end

	function love.mousepressed(...)
		graph.nodes[devices.ntags.mouse].apis.update()
	end

	function love.mousereleased(...)
		graph.nodes[devices.ntags.mouse].apis.update()
	end

	function love.keypressed(key)
		graph.nodes[devices.ntags.keyboard].apis.update(key)
	end

	function love.keyreleased(key)
		graph.nodes[devices.ntags.keyboard].apis.update(key)
	end
end

return devices
