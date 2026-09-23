local locales = {
	write = {},
	read = {},
}

function locales.init(self)
	self.translater = {}
	self.current = false
end

---@param locale string
function locales.write.setCurrent(self, locale)
	self.current = locale
end

---@param key string
function locales.read.translate(self, key)
	if not self.current then
		return key
	end
	return self.translater[self.current][key]
end

---@param locale string
---@param file string
function locales.write.add(self, locale, file)
	self.translater[locale] = require(file)
end

---@param locale string
function locales.write.del(self, locale)
	self.translater[locale] = nil
	if self.current == locale then
		self.current = false
	end
end

return locales
