local Fonts = require("softlove.assets.Fonts")
local assets = {
	Fonts = {},
}

function assets.getNodes()
	local nodes = {}

	nodes["fonts"] = {
		tasks = {
			init = {
				func = Fonts.init,
			},
		},
		apis = {},
	}

	nodes["images"] = {}
	nodes["sounds"] = {}
	nodes["shaders"] = {}

	return nodes
end

return assets
