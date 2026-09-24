local locales = {}

function locales:init()
	self.translator = {}
	self.current = false
end

---@param locale string
function locales:setCurrent(locale)
	self.current = locale
end

---@param key string
---@return string
function locales:translate(key)
	if not self.current then
		return key
	end
	return self.translator[self.current][key]
end

---@param locale string
---@param file string
function locales:add(locale, file)
	self.translator[locale] = require(file)
end

---@param locale string
function locales:del(locale)
	self.translator[locale] = nil
	if self.current == locale then
		self.current = false
	end
end

locales.read = {
	translate = locales.translate,
}

locales.write = {
	add = locales.add,
	del = locales.del,
	setCurrent = locales.setCurrent,
}

return locales
