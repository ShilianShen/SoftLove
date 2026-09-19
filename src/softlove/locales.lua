local locales = {}

local function setCurrent(self, locale)
	self.current = locale
end

local function translate(self, key)
	return self.translater[self.current][key]
end

local function init(self)
	self.translater = {}
	self.current = "en-US"
	self.translate = translate
end

local function add(self, locale, file)
	self.translater[locale] = require(file)
end

function locales.getNode()
	local node = {
		tasks = {
			init = {
				func = init,
			},
		},
		apis = {
			add = {
				func = add,
				atag = "writable",
			},
			setCurrent = {
				func = setCurrent,
				atag = "writable",
			},
		},
	}
	return node
end

return locales
