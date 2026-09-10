local softdep = require("libs.softdep")
local mouse = require("src.softlove.devices.mouse")
local keyboard = require("src.softlove.devices.keyboard")
local joystick = require("src.softlove.devices.joystick")

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

return devices
