local Ui = require("softlove.ui.Ui")
local Section = require("softlove.ui.Section")
local ui = {}

local function init(self)
	Ui.init(self)
	self.section = function(_, ...)
		Section.init(...)
	end
end

function ui.getNode()
	---@type softdep.declaration.Node
	local node = {
		tasks = {
			init = {
				func = init,
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
