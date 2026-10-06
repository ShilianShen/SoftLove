local ui = {}

local types = require("softlove.ui.types")
for k, v in pairs(types) do
	ui[k] = v
end

ui.System = require("softlove.ui.System")

---@type softdep.declaration.Api
ui.systemApiDraw = {
	func = ui.System.draw,
	dirty = false,
	atag = "writable",
}

return ui
