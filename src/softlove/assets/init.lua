local Cache = require("softlove.assets.Cache")
local assets = {}

local function check(self, obj)
	for _, type in ipairs(self.types) do
		if obj:typeOf(type) then
			return true
		end
	end
	return false
end

local function getNode(types)
	return {
		tasks = {
			init = {
				func = function(self)
					Cache.init(self)
					self.check = check
					self.types = types
				end,
			},
		},
		apis = {
			setMethod = {
				func = Cache.setMethod,
				atag = "writable",
			},
		},
	}
end

function assets.getNodes()
	return {
		fonts = getNode({ "Font" }),
		images = getNode({ "Image", "ImageData" }),
		shaders = getNode({ "Shader" }),
		source = getNode({ "Source", "SoundData" }),
	}
end

return assets
