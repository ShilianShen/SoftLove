local system = {
	Locales = require("softlove.system.Locales"),
	Window = require("softlove.system.Window"),
}

function system.getNodes()
	return {
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
				add = { func = system.Locales.add, atag = "writable" },
				del = { func = system.Locales.del, atag = "writable" },
				setCurrent = { func = system.Locales.setCurrent, atag = "writable" },
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
