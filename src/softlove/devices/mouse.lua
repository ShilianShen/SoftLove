local mouse = {
	buttons = { 1, 2, 3 },
}

function mouse:init()
	self.x1, self.y1 = 0, 0
	self.x2, self.y2 = 0, 0
	self.isDown1 = {}
	self.isDown2 = {}
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = false
		self.isDown2[bt] = false
	end
end

function mouse:update()
	self.x1, self.y1 = self.x2, self.y2
	self.x2, self.y2 = love.mouse.getPosition()
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
		self.isDown2[bt] = love.mouse.isDown(bt)
	end
end

function mouse:dynamic()
	for _, bt in pairs(self.buttons) do
		if self.isDown1[bt] ~= self.isDown2[bt] then
			return true
		end
	end
	if self.x1 ~= self.x2 or self.y1 ~= self.y2 then
		return true
	end
	return false
end

return mouse
