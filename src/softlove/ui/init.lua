local Ui = require("softlove.ui.Ui")
local Section = require("softlove.ui.Section")
local ui = {}

---@class softlove.ui.Object
---@field _x number
---@field _y number
---@field _w number
---@field _h number
---@field _layout fun(self: softlove.ui.Object, parent: softlove.ui.Object)
---@field _foreground function
---@field _background function
---@field _children softlove.ui.Object[]

---@class softlove.ui.Section
---@field entry softlove.ui.Object
---@field order table[]

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
