local locales = {}

local function setCurrent(self, locale)
	self.current = locale
end

local function translate(self, key)
	if not self.current then
		return key
	end
	return self.translater[self.current][key]
end

local function init(self)
	self.translater = {}
	self.current = false
	self.translate = translate
end

local function add(self, locale, file)
	self.translater[locale] = require(file)
end

local function del(self, locale)
	self.translater[locale] = nil
	if self.current == locale then
		self.current = false
	end
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
			del = {
				func = del,
				atag = "writable"
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
