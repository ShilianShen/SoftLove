local Window = {}

function Window:init()
	self.w, self.h = 0, 0
	self.visible = false
	self.focus = false
end

---@param focus boolean
function Window:focus(focus)
	self.focus = focus
end

---@param visible boolean
function Window:visible(visible)
	self.visible = visible
end

---@param w integer
---@param h integer
function Window:resize(w, h)
	self.w = w
	self.h = h
end

return Window
