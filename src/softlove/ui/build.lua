local util = require("src.util")
local object = require("src.ui.object")

local function build(widget)
	return function(patch)
		local merged = util.patch(patch or {}, widget, object)
		return util.copy.deepcopyDAGToTree(merged)
	end
end

return build
