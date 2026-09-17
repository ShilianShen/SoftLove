local fonts = require("softlove.assets.fonts")
local assets = {
	images = {},
	fonts = {},
	sounds = {},
	shaders = {},
}

local defaultNtags = {
	images = "images",
	fonts = "fonts",
	sounds = "sounds",
	shaders = "shaders",
}

function assets.getNodes(ntags)
	local nodes = {}
	ntags = ntags or defaultNtags
	for k, v in pairs(defaultNtags) do
		ntags[k] = ntags[k] or v
	end
	assets.ntags = ntags

	nodes[ntags.fonts] = {
		tasks = {
			init = {
				func = fonts.init,
			},
		},
		apis = {},
	}

	-- nodes[ntags.images] = {}
	-- nodes[ntags.sounds] = {}
	-- nodes[ntags.shaders] = {}

	return nodes
end

return assets
