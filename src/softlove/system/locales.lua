local Locales = {}

function Locales:init()
	self.translator = {}
	self.current = false
end

---@param locale string
function Locales:setCurrent(locale)
	self.current = locale
end

---@param key string
---@return string
function Locales:translate(key)
	if not self.current then
		return key
	end
	return self.translator[self.current][key]
end

---@param locale string
---@param file string
function Locales:add(locale, file)
	self.translator[locale] = require(file)
end

---@param locale string
function Locales:del(locale)
	self.translator[locale] = nil
	if self.current == locale then
		self.current = false
	end
end

Locales.read = {
	translate = Locales.translate,
}

Locales.write = {
	add = Locales.add,
	del = Locales.del,
	setCurrent = Locales.setCurrent,
}

return Locales
