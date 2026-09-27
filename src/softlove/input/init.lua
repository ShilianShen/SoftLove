Mouse = require("softlove.input.Mouse")
Keyboard = require("softlove.input.Keyboard")
Joysticks = require("softlove.input.Joysticks")
Wheel = require("softlove.input.Wheel")
local input = {}

local function getTasks(x)
	local tasks = {
		init = { func = x.init },
		update = {
			func = x.update,
			parents_c = { "init" },
			auto = x.isDynamic,
		},
	}
	return tasks
end

function input.getNodes()
	return {
		joysticks = {
			tasks = getTasks(Joysticks),
			apis = {
				added = { func = Joysticks.added, atag = "writable" },
				removed = { func = Joysticks.removed, atag = "writable" },
				pressed = { func = Joysticks.pressed, atag = "writable" },
				released = { func = Joysticks.released, atag = "writable" },
				axis = { func = Joysticks.axis, atag = "writable" },
				hat = { func = Joysticks.hat, atag = "writable" },
				gamepadpressed = { func = Joysticks.gamepadpressed, atag = "writable" },
				gamepadreleased = { func = Joysticks.gamepadreleased, atag = "writable" },
				gamepadaxis = { func = Joysticks.gamepadaxis, atag = "writable" },
			},
		},
		mouse = {
			tasks = getTasks(Mouse),
			apis = {
				moved = { func = Mouse.moved, atag = "writable" },
				pressed = { func = Mouse.pressed, atag = "writable" },
				released = { func = Mouse.released, atag = "writable" },
				focus = { func = Mouse.focus, atag = "writable" },
			},
		},
		keyboard = {
			tasks = getTasks(Keyboard),
			apis = {
				pressed = { func = Keyboard.pressed, atag = "writable" },
				released = { func = Keyboard.released, atag = "writable" },
			},
		},
		wheel = {
			tasks = getTasks(Wheel),
			apis = {
				moved = { func = Wheel.moved, atag = "writable" },
			},
		},
	}
end

function input.getCallbacks(nodes)
	return {
		joystickadded = nodes.joysticks.apis.added,
		joystickremoved = nodes.joysticks.apis.removed,
		joystickpressed = nodes.joysticks.apis.pressed,
		joystickreleased = nodes.joysticks.apis.released,
		joystickaxis = nodes.joysticks.apis.axis,
		joystickhat = nodes.joysticks.apis.hat,
		gamepadpressed = nodes.joysticks.apis.pressed,
		gamepadreleased = nodes.joysticks.apis.released,
		gamepadaxis = nodes.joysticks.apis.axis,

		mousemoved = nodes.mouse.apis.moved,
		mousepressed = nodes.mouse.apis.pressed,
		mousereleased = nodes.mouse.apis.released,
		mousefocus = nodes.mouse.apis.focus,

		keypressed = nodes.keyboard.apis.pressed,
		keyreleased = nodes.keyboard.apis.released,

		wheelmoved = nodes.wheel.apis.moved,
	}
end

return input
