local util = require("softlove.ui.util")
local object = require("softlove.ui.object")

local function build(widget)
	return function(patch)
		local merged = util.patch(patch or {}, widget, object)
		return util.deepcopyDAGToTree(merged)
	end
end

return build
