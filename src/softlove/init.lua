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
				update = {
					func = system.window.update,
				},
			},
			apis = {
				update = { ttag = "update" },
			},
		},
		locales = {
			tasks = {
				init = {
					func = function(self)
						system.locales.init(self)
						union(self, system.locales.read)
					end,
				},
			},
			apis = {
				add = {
					func = system.locales.write.add,
					atag = "writable",
				},
				del = {
					func = system.locales.write.del,
					atag = "writable",
				},
				setCurrent = {
					func = system.locales.write.setCurrent,
					atag = "writable",
				},
			},
		},
		mouse = {
			tasks = {
				init = {
					func = input.mouse.init,
				},
				update = {
					func = input.mouse.update,
					parents_c = { "init" },
					auto = input.mouse.dynamic,
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
					func = input.keyboard.init,
				},
				update = {
					func = input.keyboard.update,
					parents_c = { "init" },
					auto = input.keyboard.dynamic,
				},
			},
			apis = {
				update = {
					func = input.keyboard.write.newKey,
					ttag = "update",
					atag = "writable",
				},
			},
		},
		wheel = {
			tasks = {
				init = {
					func = input.wheel.init,
				},
				update = {
					func = input.wheel.update,
					parents_c = { "init" },
					auto = input.wheel.dynamic,
				},
			},
			apis = {
				moved = {
					func = input.wheel.write.moved,
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
		focus = node.apis.update,
		visible = node.apis.update,
		resize = node.apis.update,
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
