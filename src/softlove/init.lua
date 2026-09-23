local devices = require("softlove.devices")

local softlove = {
	drawGraph = require("softlove.drawGraph"),
	assets = require("softlove.assets"),
	ui = require("softlove.ui"),
	locales = require("softlove.locales"),
	window = require("softlove.window"),
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
					func = softlove.window.update,
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
						softlove.locales.init(self)
						union(self, softlove.locales.read)
					end,
				},
			},
			apis = {
				add = {
					func = softlove.locales.write.add,
					atag = "writable",
				},
				del = {
					func = softlove.locales.write.del,
					atag = "writable",
				},
				setCurrent = {
					func = softlove.locales.write.setCurrent,
					atag = "writable",
				},
			},
		},
		mouse = {
			tasks = {
				init = {
					func = devices.mouse.init,
				},
				update = {
					func = devices.mouse.update,
					parents_c = { "init" },
					auto = devices.mouse.dynamic,
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
					func = devices.keyboard.init,
				},
				update = {
					func = devices.keyboard.update,
					parents_c = { "init" },
					auto = devices.keyboard.dynamic,
				},
			},
			apis = {
				update = {
					func = devices.keyboard.write.newKey,
					ttag = "update",
					atag = "writable",
				},
			},
		},
		wheel = {
			tasks = {
				init = {
					func = devices.wheel.init,
				},
				update = {
					func = devices.wheel.update,
					parents_c = { "init" },
					auto = devices.wheel.dynamic,
				},
			},
			apis = {
				moved = {
					func = devices.wheel.write.moved,
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
