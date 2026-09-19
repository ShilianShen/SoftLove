local window = {}
local ntags = require("softlove.ntags")

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

function window.setCallbacks(graph)
	love.focus = graph.nodes[ntags.window].apis.update
	love.visible = graph.nodes[ntags.window].apis.update
	love.resize = graph.nodes[ntags.window].apis.update
	-- love.displayrotated = function(displayindex, orientation) end
end

return window
