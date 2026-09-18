local window = {}
local ntags = require("softlove.ntags")

function window.getNode()
	local node = {
		tasks = {
			init = {
				func = function(self)
					self.w, self.h = love.graphics.getDimensions()
				end,
			},
			update = {
				func = function(self)
					self.w, self.h = love.graphics.getDimensions()
				end,
				parents_c = { "init" },
			},
		},
		apis = {
			resize = {
				ttag = "update",
			},
		},
	}
	return node
end

function window.setCallbacks(graph)
	love.focus = function(focus) end
	love.visible = function(visible) end
	love.resize = function(w, h)
		graph.nodes[ntags.window].apis.resize()
	end
	love.displayrotated = function(displayindex, orientation) end
end

return window
