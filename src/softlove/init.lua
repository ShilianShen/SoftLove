local input = require("softlove.input")
local system = require("softlove.system")
local softlove = {
	drawGraph = require("softlove.drawGraph"),
	assets = require("softlove.assets"),
	ui = require("softlove.ui"),
	ntags = require("softlove.ntags"),
}

local function union(self, other)
	for k, v in pairs(other) do
		assert(self[k] == nil)
		self[k] = v
	end
end

local function getInputStateTasks(x)
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

function softlove.getNodes()
	local nodes = {
		window = {
			tasks = {
				init = {
					func = system.Window.init,
				},
				update = {
					func = system.Window.update,
					parents_c = { "init" },
				},
			},
			apis = {
				focus = { func = system.Window.focus, atag = "writable" },
				visible = { func = system.Window.visible, atag = "writable" },
				resize = { func = system.Window.resize, atag = "writable" },
			},
		},
		locales = {
			tasks = {
				init = {
					func = function(self)
						system.Locales.init(self)
						self.translate = system.Locales.translate
					end,
				},
			},
			apis = {
				add = {
					func = system.Locales.add,
					atag = "writable",
				},
				del = {
					func = system.Locales.del,
					atag = "writable",
				},
				setCurrent = {
					func = system.Locales.setCurrent,
					atag = "writable",
				},
			},
		},
		joystick = {
			tasks = getInputStateTasks(input.Joystick),
			apis = {
				added = { func = input.Joystick.added, atag = "writable" },
				removed = { func = input.Joystick.removed, atag = "writable" },
				pressed = { func = input.Joystick.pressed, atag = "writable" },
				released = { func = input.Joystick.released, atag = "writable" },
				axis = { func = input.Joystick.axis, atag = "writable" },
				hat = { func = input.Joystick.hat, atag = "writable" },
				gamepadpressed = { func = input.Joystick.gamepadpressed, atag = "writable" },
				gamepadreleased = { func = input.Joystick.gamepadreleased, atag = "writable" },
				gamepadaxis = { func = input.Joystick.gamepadaxis, atag = "writable" },
			},
		},
		mouse = {
			tasks = getInputStateTasks(input.Mouse),
			apis = {
				moved = { func = input.Mouse.moved, atag = "writable" },
				pressed = { func = input.Mouse.pressed, atag = "writable" },
				released = { func = input.Mouse.released, atag = "writable" },
				focus = { func = input.Mouse.focus, atag = "writable" },
			},
		},
		keyboard = {
			tasks = getInputStateTasks(input.Keyboard),
			apis = {
				pressed = { func = input.Keyboard.pressed, atag = "writable" },
				released = { func = input.Keyboard.released, atag = "writable" },
			},
		},
		wheel = {
			tasks = getInputStateTasks(input.Wheel),
			apis = {
				moved = { func = input.Wheel.moved, atag = "writable" },
			},
		},
	}
	return nodes
end

function softlove.getCallbacksWindow(node)
	-- love.displayrotated = function(displayindex, orientation) end
	return {
		focus = node.apis.focus,
		visible = node.apis.visible,
		resize = node.apis.resize,
	}
end

function softlove.getCallbacksJoystick(node)
	return {
		joystickadded = node.apis.added,
		joystickremoved = node.apis.removed,
		joystickpressed = node.apis.pressed,
		joystickreleased = node.apis.released,
		joystickaxis = node.apis.axis,
		joystickhat = node.apis.hat,
		gamepadpressed = node.apis.pressed,
		gamepadreleased = node.apis.released,
		gamepadaxis = node.apis.axis,
	}
end

function softlove.getCallbacksMouse(node)
	return {
		mousemoved = node.apis.moved,
		mousepressed = node.apis.pressed,
		mousereleased = node.apis.released,
		mousefocus = node.apis.focus,
	}
end

function softlove.getCallbacksKeyboard(node)
	return {
		keypressed = node.apis.pressed,
		keyreleased = node.apis.released,
	}
end

function softlove.getCallbacksWheel(node)
	return {
		wheelmoved = node.apis.moved,
	}
end

return softlove
