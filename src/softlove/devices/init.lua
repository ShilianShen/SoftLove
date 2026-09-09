local softdep = require("libs.softdep_local")
local mouse = require("src.softlove.devices.mouse")
local keyboard = require("src.softlove.devices.keyboard")

local devices = {
	mouse = {
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
	},
	keyboard = {
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
	},
}

return devices
