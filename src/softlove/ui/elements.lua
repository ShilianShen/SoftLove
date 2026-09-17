local elements = {}

local function drawRectangle(self)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

local function drawPoint(self)
	love.graphics.rectangle("fill", self.x - 1, self.y - 1, 2, 2)
end

elements.object = function(config, layout)
	local node = {
		tasks = {
			layout = layout,
		},
		apis = {},
	}
	return node
end

elements.rectangle = function(config, layout)
	local node = elements.object(config, layout)
	node.apis.draw = {
		func = drawRectangle,
	}
	return node
end

elements.point = function(config, layout)
	local node = elements.object(config, layout)
	node.apis.draw = {
		func = drawPoint,
	}
	return node
end

return elements
