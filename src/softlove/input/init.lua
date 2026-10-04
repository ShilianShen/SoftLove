Mouse = require("softlove.input.Mouse")
Keyboard = require("softlove.input.Keyboard")
Joysticks = require("softlove.input.Joysticks")
Wheel = require("softlove.input.Wheel")
local inspect = require("softlove.inspect")
local input = {}

local function isDynamic(x)
	return x:isDynamic()
end

local function getTasks(x)
	local tasks = {
		init = { func = x.init, atag = "writable", back = false },
		step = {
			func = x.step,
			parents_c = { "init" },
			-- auto = isDynamic,
			atag = "writable",
			back = true,
		},
	}
	return tasks
end

function input.getNodes()
	return {
		joysticks = {
			tasks = getTasks(Joysticks),
			apis = {
				added = { func = Joysticks.added, atag = "writable", dirty = true },
				removed = { func = Joysticks.removed, atag = "writable", dirty = true },
				pressed = { func = Joysticks.pressed, atag = "writable", dirty = true },
				released = { func = Joysticks.released, atag = "writable", dirty = true },
				axis = { func = Joysticks.axis, atag = "writable", dirty = true },
				hat = { func = Joysticks.hat, atag = "writable", dirty = true },
				gamepadpressed = { func = Joysticks.gamepadpressed, atag = "writable", dirty = true },
				gamepadreleased = { func = Joysticks.gamepadreleased, atag = "writable", dirty = true },
				gamepadaxis = { func = Joysticks.gamepadaxis, atag = "writable", dirty = true },
			},
			atag = "readonly",
		},
		mouse = {
			tasks = getTasks(Mouse),
			apis = {
				moved = { func = Mouse.moved, atag = "writable", dirty = true },
				pressed = { func = Mouse.pressed, atag = "writable", dirty = true },
				released = { func = Mouse.released, atag = "writable", dirty = true },
				focus = { func = Mouse.focus, atag = "writable", dirty = true },
			},
			atag = "readonly",
		},
		keyboard = {
			tasks = getTasks(Keyboard),
			apis = {
				pressed = { func = Keyboard.pressed, atag = "writable", dirty = true },
				released = { func = Keyboard.released, atag = "writable", dirty = true },
			},
			atag = "readonly",
		},
		wheel = {
			tasks = getTasks(Wheel),
			apis = {
				moved = { func = Wheel.moved, atag = "writable", dirty = true },
			},
			atag = "readonly",
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
