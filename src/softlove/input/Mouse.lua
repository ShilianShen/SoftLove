local Mouse = {}

function Mouse:init()
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

local function switch(self)
	self.x1, self.y1 = self.x2, self.y2
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
	end
	self.focus1 = self.focus2
end

function Mouse:update()
	self.x1, self.y1 = self.x2, self.y2
	self.x2, self.y2 = love.mouse.getPosition()
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
		self.isDown2[bt] = love.mouse.isDown(bt)
	end
	self.focus1 = self.focus2
	self.focus2 = love.window.hasMouseFocus()
end

function Mouse:isDynamic()
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

function Mouse:pressed(x, y, button, istouch, presses)
	self.isDown2[button] = true
	self.idk = true
end

function Mouse:released(x, y, button, istouch, presses)
	self.isDown2[button] = false
	self.idk = true
end

function Mouse:moved(x, y, dx, dy, istouch)
	self.x2 = x
	self.y2 = y
	self.idk = true
end

function Mouse:focus(focus)
	self.focus2 = focus
	self.idk = true
end

return Mouse
