local fonts = require("softlove.assets.fonts")
local ntags = require("softlove.ntags")
local assets = {
	images = {},
	fonts = {},
	sounds = {},
	shaders = {},
}

function assets.getNodes()
	local nodes = {}

	nodes[ntags.assets.fonts] = {
		tasks = {
			init = {
				func = fonts.init,
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
