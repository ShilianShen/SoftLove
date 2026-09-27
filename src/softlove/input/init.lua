local input = {
	Mouse = require("softlove.input.Mouse"),
	Keyboard = require("softlove.input.Keyboard"),
	Joysticks = require("softlove.input.Joysticks"),
	Wheel = require("softlove.input.Wheel"),
}

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
			tasks = getTasks(input.Joysticks),
			apis = {
				added = { func = input.Joysticks.added, atag = "writable" },
				removed = { func = input.Joysticks.removed, atag = "writable" },
				pressed = { func = input.Joysticks.pressed, atag = "writable" },
				released = { func = input.Joysticks.released, atag = "writable" },
				axis = { func = input.Joysticks.axis, atag = "writable" },
				hat = { func = input.Joysticks.hat, atag = "writable" },
				gamepadpressed = { func = input.Joysticks.gamepadpressed, atag = "writable" },
				gamepadreleased = { func = input.Joysticks.gamepadreleased, atag = "writable" },
				gamepadaxis = { func = input.Joysticks.gamepadaxis, atag = "writable" },
			},
		},
		mouse = {
			tasks = getTasks(input.Mouse),
			apis = {
				moved = { func = input.Mouse.moved, atag = "writable" },
				pressed = { func = input.Mouse.pressed, atag = "writable" },
				released = { func = input.Mouse.released, atag = "writable" },
				focus = { func = input.Mouse.focus, atag = "writable" },
			},
		},
		keyboard = {
			tasks = getTasks(input.Keyboard),
			apis = {
				pressed = { func = input.Keyboard.pressed, atag = "writable" },
				released = { func = input.Keyboard.released, atag = "writable" },
			},
		},
		wheel = {
			tasks = getTasks(input.Wheel),
			apis = {
				moved = { func = input.Wheel.moved, atag = "writable" },
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
