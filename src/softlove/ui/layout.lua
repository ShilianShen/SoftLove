local layout = {}

function layout.copy(self, parent)
	self.x = parent.x
	self.y = parent.y
	self.w = parent.w
	self.h = parent.h
end

function layout.anchor(self, parent)
	self.w, self.h = self.drawable:getDimensions()

	local ax = parent.x + parent.w * (self.u1 or 0)
	local ay = parent.y + parent.h * (self.v1 or 0)

	self.x = ax - self.w * (self.u2 or 0)
	self.y = ay - self.h * (self.v2 or 0)
end

function layout.anchorRWRH(self, parent)
	self.w = self.rw * parent.w
	self.h = self.rh * parent.h

	local ax = parent.x + parent.w * (self.u1 or 0)
	local ay = parent.y + parent.h * (self.v1 or 0)

	self.x = ax - self.w * (self.u2 or 0)
	self.y = ay - self.h * (self.v2 or 0)
end

return layout
