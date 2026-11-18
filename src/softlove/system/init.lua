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

function system.Window()
	return window
end

return system
