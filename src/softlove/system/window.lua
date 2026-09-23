local window = {
	read = {},
	write = {},
}

function window.update(self)
	self.w, self.h = love.graphics.getDimensions()
	self.visible = love.window.isVisible()
	self.focus = love.window.hasFocus()
end

return window
