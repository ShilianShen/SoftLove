local Fonts = {}

---@class softlove.assets.Fonts
---@field fonts table<string, love.Font>
---@field texts table<string, love.Text>
---@field getDimensions fun(self: softlove.assets.Fonts, key: string, text: string): number, number
---@field print fun(self: softlove.assets.Fonts, key: string, text: string, ...)

---@param self table
function Fonts.init(self)
	self.fonts = {}
	self.texts = {}
	self.getDimensions = Fonts.getDimensions
	self.print = Fonts.print
	self.printt = Fonts.printt
end

---@param self softlove.assets.Fonts
---@param key string
---@param font love.Font
function Fonts.setFont(self, key, font)
	self.fonts[key] = font
end

---@param self softlove.assets.Fonts
---@param key string
---@param fontKey string
function Fonts.setText(self, key, fontKey, ...)
	local font = self.fonts[fontKey]
	self.texts[key] = love.graphics.newText(font, ...)
end

---@param self softlove.assets.Fonts
---@param key string
---@param text string
---@return number, number
function Fonts.getDimensions(self, key, text)
	local font = self.fonts[key]
	return font:getWidth(text), font:getHeight()
end

---@param self softlove.assets.Fonts
---@param key string
function Fonts.print(self, key, text, ...)
	local font = self.fonts[key]
	love.graphics.print(text, font, ...)
end

---@param self softlove.assets.Fonts
---@param textKey string
function Fonts.printt(self, textKey, ...)
	local text = self.texts[textKey]
	love.graphics.draw(text, ...)
end

return Fonts
