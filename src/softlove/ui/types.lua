local types = {}

local function drawRectangle(self)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

local function drawPoint(self)
	local r = 3
	love.graphics.rectangle("fill", self.x - r, self.y - r, 2 * r, 2 * r)
end

types.object = function(config, layout)
	local node = {
		tasks = {
			layout = layout,
		},
		apis = {
			draw = {},
		},
	}
	return node
end

types.rectangle = function(config, layout)
	local node = types.object(config, layout)
	node.apis.draw = {
		func = drawRectangle,
	}
	return node
end

types.point = function(config, layout)
	local node = types.object(config, layout)
	node.apis.draw = {
		func = drawPoint,
	}
	return node
end

return types
