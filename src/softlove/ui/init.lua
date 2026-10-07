local Ui = require("softlove.ui.Ui")
local ui = {
	Section = require("softlove.ui.Section"),
}

function ui.getNode()
	---@type softdep.declaration.Node
	local node = {
		tasks = {
			init = {
				func = Ui.init,
				atag = "writable",
				back = false,
			},
		},
		apis = {
			newPatch = { func = Ui.newPatch, atag = "writable", dirty = true },
		},
		atag = "readonly",
	}
	return node
end

return ui
