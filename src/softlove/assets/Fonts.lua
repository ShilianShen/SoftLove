local fonts = {}

local function newFont(self, filename, size)
	self.fonts[filename] = self.fonts[filename] or {}
	self.fonts[filename][size] = love.graphics.newFont(filename, size)
end

local function getFont(self, filename, size)
	if self.fonts[filename] == nil or self.fonts[filename][size] == nil then
		newFont(self, filename, size)
	end
	return self.fonts[filename][size]
end

function fonts:init()
	self.fonts = {}
	self.newFont = newFont
	self.getFont = getFont
end

return fonts
