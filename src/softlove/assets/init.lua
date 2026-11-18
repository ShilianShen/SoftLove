local Cache = require("softlove.assets.Cache")
local Locales = require("softlove.assets.Locales")
local assets = {}

local function check(self, obj)
	for _, type in ipairs(self.types) do
		if obj:typeOf(type) then
			return true
		end
	end
	return false
end

local function getNode(types, methods)
	return {
		tasks = {
			init = {
				func = function(self)
					Cache.init(self)
					self.check = check
					self.types = types
					for method, func in pairs(methods or {}) do
						Cache.setMethod(self, method, func)
					end
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

function assets.Fonts()
	return getNode({ "Font" }, {
		newFont = love.graphics.newFont,
		newImageFont = love.graphics.newImageFont,
	})
end

function assets.Images()
	return getNode({ "Image", "ImageData" }, {
		newImage = love.graphics.newImage,
		newImageData = love.image.newImageData,
	})
end

function assets.Shaders()
	return getNode({ "Shader" }, {
		newShader = love.graphics.newShader,
	})
end

function assets.Sources()
	return getNode({ "Source", "SoundData" }, {
		newSource = love.audio.newSource,
		newSoundData = love.sound.newSoundData,
	})
end

function assets.Locales()
	return {
		tasks = {
			init = {
				func = function(self)
					Locales.init(self)
					self.translate = Locales.translate
				end,
				atag = "writable",
				back = false,
			},
		},
		apis = {
			add = { func = Locales.add, atag = "writable", dirty = true },
			del = { func = Locales.del, atag = "writable", dirty = true },
			setCurrent = { func = Locales.setCurrent, atag = "writable", dirty = true },
		},
		atag = "readonly",
	}
end

return assets
