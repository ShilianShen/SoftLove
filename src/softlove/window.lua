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

function window.getCallbacks(node)
	-- love.displayrotated = function(displayindex, orientation) end
	return {
		focus = node.apis.update,
		visible = node.apis.update,
		resize = node.apis.update,
	}
end

return window
