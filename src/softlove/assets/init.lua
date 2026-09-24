local Fonts = require("softlove.assets.Fonts")
local ntags = require("softlove.ntags")
local assets = {
	Fonts = {},
}

function assets.getNodes()
	local nodes = {}

	nodes[ntags.assets.fonts] = {
		tasks = {
			init = {
				func = Fonts.init,
			},
		},
		apis = {},
	}

	nodes[ntags.assets.images] = {}
	nodes[ntags.assets.sounds] = {}
	nodes[ntags.assets.shaders] = {}

	return nodes
end

return assets
