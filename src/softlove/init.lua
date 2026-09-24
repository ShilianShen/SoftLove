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
		mouse = {
			tasks = {
				init = {
					func = input.Mouse.init,
				},
				update = {
					func = input.Mouse.update,
					parents_c = { "init" },
					auto = input.Mouse.dynamic,
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
					func = input.Keyboard.init,
				},
				update = {
					func = input.Keyboard.update,
					parents_c = { "init" },
					auto = input.Keyboard.dynamic,
				},
			},
			apis = {
				update = {
					func = input.Keyboard.write.newKey,
					ttag = "update",
					atag = "writable",
				},
			},
		},
		wheel = {
			tasks = {
				init = {
					func = input.Wheel.init,
				},
				update = {
					func = input.Wheel.update,
					parents_c = { "init" },
					auto = input.Wheel.dynamic,
				},
			},
			apis = {
				moved = {
					func = input.Wheel.write.moved,
					atag = "writable",
				},
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

function softlove.getCallbacksMouse(node)
	return {
		mousemoved = node.apis.update,
		mousepressed = node.apis.update,
		mousereleased = node.apis.update,
		mousefocus = node.apis.update,
	}
end

function softlove.getCallbacksKeyboard(node)
	return {
		keypressed = node.apis.update,
		keyreleased = node.apis.update,
	}
end

function softlove.getCallbacksWheel(node)
	return {
		wheelmoved = node.apis.moved,
	}
end

return softlove
