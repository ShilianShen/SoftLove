local wheel = {
	read = {},
	write = {},
}

function wheel.init(self)
	self.dx = 0
	self.dy = 0
	self.move1 = false
	self.move2 = false
end

function wheel.write.moved(self, dx, dy)
	self.dx = dx
	self.dy = dy
	self.move2 = true
end

function wheel.dynamic(self)
	return self.move1 or self.move2
end

function wheel.update(self)
	self.move1 = self.move2

	if not self.move2 then
		self.dx = 0
		self.dy = 0
	end

	self.move2 = false
end

return wheel
