local Locales = require("softlove.system.Locales")
local Window = require("softlove.system.Window")
local system = {}

local window = {
	tasks = {
		init = {
			func = Window.init,
			back = false,
			atag = "writable",
		},
		update = {
			func = Window.update,
			parents_c = { "init" },
			back = false,
			atag = "writable",
		},
	},
	apis = {
		focus = { func = Window.focus, atag = "writable", dirty = true },
		visible = { func = Window.visible, atag = "writable", dirty = true },
		resize = { func = Window.resize, atag = "writable", dirty = true },
	},
	atag = "readonly",
}

local locales = {
	tasks = {
		init = {
			func = function(self)
				Locales.init(self)
				self.translate = Locales.translate
			end,
			atag = "writable",
			back = false,
		},
	},
	apis = {
		add = { func = Locales.add, atag = "writable", dirty = true },
		del = { func = Locales.del, atag = "writable", dirty = true },
		setCurrent = { func = Locales.setCurrent, atag = "writable", dirty = true },
	},
	atag = "readonly",
}

function system.Window()
	return window
end

function system.Locales()
	return locales
end

return system
