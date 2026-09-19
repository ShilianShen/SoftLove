local window = {}

function window.getNode()
	local node = {
		tasks = {
			update = {
				func = function(self)
					self.w, self.h = love.graphics.getDimensions()
					self.visible = love.window.isVisible()
					self.focus = love.window.hasFocus()
				end,
			},
		},
		apis = {
			update = { ttag = "update" },
		},
	}
	return node
end

function window.setCallbacks(node)
	love.focus = node.apis.update
	love.visible = node.apis.update
	love.resize = node.apis.update
	-- love.displayrotated = function(displayindex, orientation) end
end

return window
