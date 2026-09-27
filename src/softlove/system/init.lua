local Locales = require("softlove.system.Locales")
local Window = require("softlove.system.Window")
local system = {}

function system.getNodes()
	return {
		window = {
			tasks = {
				init = {
					func = Window.init,
				},
				update = {
					func = Window.update,
					parents_c = { "init" },
				},
			},
			apis = {
				focus = { func = Window.focus, atag = "writable" },
				visible = { func = Window.visible, atag = "writable" },
				resize = { func = Window.resize, atag = "writable" },
			},
		},
		locales = {
			tasks = {
				init = {
					func = function(self)
						Locales.init(self)
						self.translate = Locales.translate
					end,
				},
			},
			apis = {
				add = { func = Locales.add, atag = "writable" },
				del = { func = Locales.del, atag = "writable" },
				setCurrent = { func = Locales.setCurrent, atag = "writable" },
			},
		},
	}
end

function system.getCallbacks(nodes)
	return {
		focus = nodes.window.apis.focus,
		resize = nodes.window.apis.resize,
		visible = nodes.window.apis.visible,
	}
end

return system
