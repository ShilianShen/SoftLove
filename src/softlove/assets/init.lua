local Cache = require("softlove.assets.Cache")
local Fonts = require("softlove.assets.Fonts")
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
				atag = "writable",
				back = false,
			},
		},
		apis = {
			setMethod = {
				func = Cache.setMethod,
				atag = "writable",
				dirty = true,
			},
		},
		atag = "readonly",
	}
end

function assets.getNodes()
	return {
		---@type softdep.declaration.Node
		fonts = {
			tasks = {
				init = { func = Fonts.init, back = false, atag = "writable" },
			},
			apis = {
				setFont = { func = Fonts.setFont, atag = "writable", dirty = true },
				setText = { func = Fonts.setText, atag = "writable", dirty = true },
			},
			atag = "readonly",
		},
		-- fonts = getNode({ "Font" }),
		images = getNode({ "Image", "ImageData" }),
		shaders = getNode({ "Shader" }),
		source = getNode({ "Source", "SoundData" }),
	}
end

return assets
