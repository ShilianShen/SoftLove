local mouse = {
	read = {},
	write = {},
}

function mouse.init(self)
	self.buttons = { 1, 2, 3 }
	self.x1, self.y1 = 0, 0
	self.x2, self.y2 = 0, 0
	self.focus1 = false
	self.focus2 = false
	self.isDown1 = {}
	self.isDown2 = {}
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = false
		self.isDown2[bt] = false
	end
end

function mouse.update(self)
	self.x1, self.y1 = self.x2, self.y2
	self.x2, self.y2 = love.mouse.getPosition()
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
		self.isDown2[bt] = love.mouse.isDown(bt)
	end
	self.focus1 = self.focus2
	self.focus2 = love.window.hasMouseFocus()
end

function mouse.dynamic(self)
	for _, bt in pairs(self.buttons) do
		if self.isDown1[bt] ~= self.isDown2[bt] then
			return true
		end
	end
	if self.x1 ~= self.x2 or self.y1 ~= self.y2 then
		return true
	end
	if self.focus1 ~= self.focus2 then
		return true
	end
	return false
end

return mouse
