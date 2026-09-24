local Window = {
	read = {},
	write = {},
}

function Window.update(self)
	self.w, self.h = love.graphics.getDimensions()
	self.visible = love.window.isVisible()
	self.focus = love.window.hasFocus()
end

return Window
