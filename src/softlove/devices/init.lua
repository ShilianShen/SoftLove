local ntags = require("softlove.ntags")
local devices = {
	mouse = require("softlove.devices.mouse"),
	keyboard = require("softlove.devices.keyboard"),
	joystick = require("softlove.devices.joystick"),
	wheel = require("softlove.devices.wheel"),
	touch = require("softlove.devices.touch"),
}

function devices.getNodes()
	local nodes = {}

	nodes[ntags.devices.mouse] = devices.mouse.getNode()
	nodes[ntags.devices.keyboard] = devices.keyboard.getNode()
	nodes[ntags.devices.joystick] = {}
	nodes[ntags.devices.wheel] = {}
	nodes[ntags.devices.touch] = {}

	return nodes
end

return devices
