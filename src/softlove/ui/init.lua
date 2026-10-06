local ui = {}

local types = require("softlove.ui.types")
for k, v in pairs(types) do
	ui[k] = v
end

ui.System = require("softlove.ui.System")

return ui
