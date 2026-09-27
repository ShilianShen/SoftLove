local input = require("softlove.input")
local system = require("softlove.system")
local softlove = {
	drawGraph = require("softlove.drawGraph"),
	assets = require("softlove.assets"),
	ui = require("softlove.ui"),
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
		fonts = {},
	}
	union(nodes, input.getNodes())
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

softlove.getCallbacksInput = input.getCallbacks

return softlove
