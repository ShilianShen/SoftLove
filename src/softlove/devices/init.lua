local mouse = require("softlove.devices.mouse")
local keyboard = require("softlove.devices.keyboard")
local joystick = require("softlove.devices.joystick")
local wheel = require("softlove.devices.wheel")
local ntags = require("softlove.ntags")

local devices = {
	mouse = mouse,
	keyboard = keyboard,
}

function devices.getNodes()
	local nodes = {}

	nodes[ntags.devices.mouse] = mouse.getNode()
	nodes[ntags.devices.keyboard] = keyboard.getNode()
	nodes[ntags.devices.joystick] = {}
	nodes[ntags.devices.wheel] = {}

	return nodes
end

function devices.setCallbacks(graph)
	mouse.setCallbacks(graph)
	keyboard.setCallbacks(graph)
end

return devices
