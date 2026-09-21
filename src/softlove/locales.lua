local locales = {
	setter = {},
	getter = {},
}

function locales.setter.setCurrent(self, locale)
	self.current = locale
end

function locales.getter.translate(self, key)
	if not self.current then
		return key
	end
	return self.translater[self.current][key]
end

function locales.init(self)
	self.translater = {}
	self.current = false
	self.translate = locales.getter.translate
end

function locales.setter.add(self, locale, file)
	self.translater[locale] = require(file)
end

function locales.setter.del(self, locale)
	self.translater[locale] = nil
	if self.current == locale then
		self.current = false
	end
end

function locales.getNode()
	local node = {
		tasks = {
			init = {
				func = locales.init,
			},
		},
		apis = {
			add = {
				func = locales.setter.add,
				atag = "writable",
			},
			del = {
				func = locales.setter.del,
				atag = "writable",
			},
			setCurrent = {
				func = locales.setter.setCurrent,
				atag = "writable",
			},
		},
	}
	return node
end

return locales
