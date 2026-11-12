local layout = {}

---@param self softlove.ui.Widget
---@param parent softlove.ui.Widget
function layout.copy(self, parent)
	self.x = parent.x
	self.y = parent.y
	self.w = parent.w
	self.h = parent.h
end

---@param self softlove.ui.Widget
---@param parent softlove.ui.Widget
function layout.anchor(self, parent)
	self.w, self.h = self.state.drawable:getDimensions()

	local ax = parent.x + parent.w * (self.state.u1 or 0)
	local ay = parent.y + parent.h * (self.state.v1 or 0)

	self.x = ax - self.w * (self.state.u2 or 0)
	self.y = ay - self.h * (self.state.v2 or 0)
end

---@param self softlove.ui.Widget
---@param parent softlove.ui.Widget
function layout.anchorRWRH(self, parent)
	self.w = self.state.rw * parent.w
	self.h = self.state.rh * parent.h

	local ax = parent.x + parent.w * (self.state.u1 or 0)
	local ay = parent.y + parent.h * (self.state.v1 or 0)

	self.x = ax - self.w * (self.state.u2 or 0)
	self.y = ay - self.h * (self.state.v2 or 0)
end

return layout
