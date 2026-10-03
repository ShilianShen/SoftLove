local Content = require("softlove.drawGraph.Content")
local getDAG = require("softlove.drawGraph.getDAG")
local inspect = require("softlove.inspect")

local drawGraph = {
	colors = {
		background = { 0.025, 0.025, 0.025, 0.7 },

		point = { 0.90, 0.35, 0.25 },
		text = { 0.88, 0.88, 0.84 },
		border = { 0.72, 0.72, 0.68 },
		surface = { 0.055, 0.055, 0.050 },

		accent_border = { 0.72, 0.58, 0.12 },
		accent_surface = { 0.12, 0.10, 0.04 },

		warning = { 0.95, 0.40, 0.18 },
		success = { 0.40, 0.85, 0.45 },
	},
	ntag = nil,
	ttag = nil,
	defaultNode = { tasks = {}, parents_c = {}, children_c = {}, order_c = {} },
}

function drawGraph:setFont(font)
	self.font = font
	self.drawable = love.graphics.newText(self.font)
end

function drawGraph:call(graph)
	local rw = 0.6
	local rh = 0.6
	local W, H = love.graphics.getDimensions()
	local mouseX, mouseY = love.mouse.getPosition()

	local nodesContent =
		getDAG(graph.nodes, graph.parents_n, graph.children_n, graph.order_n, self.ntag, 0, 0, W * rw, H * rh)

	for ntag, text in pairs(nodesContent.texts) do
		local x = text.x
		local y = text.y
		local w = self.font:getWidth(text.t)
		local h = self.font:getHeight()
		if mouseX >= x - w / 2 and mouseX <= x + w / 2 and mouseY >= y - h / 2 and mouseY <= y + h / 2 then
			self.ntag = ntag
			self.ttag = nil
			break
		end
	end

	local node = self.ntag and graph.nodes[self.ntag] or self.defaultNode
	local tasksContent =
		getDAG(node.tasks, node.parents_c, node.children_c, node.order_c, self.ttag, 0, H * rh, W * rw, H * (1 - rh))

	for ttag, text in pairs(tasksContent.texts) do
		local x = text.x
		local y = text.y
		local w = self.font:getWidth(text.t)
		local h = self.font:getHeight()
		if mouseX >= x - w / 2 and mouseX <= x + w / 2 and mouseY >= y - h / 2 and mouseY <= y + h / 2 then
			self.ttag = ttag
			break
		end
	end

	local content = Content.union({ n = nodesContent, t = tasksContent })

	if self.ntag and self.ttag then
		for _, ptag in pairs(graph.parents_d[self.ntag][self.ttag]) do
			local x1 = nodesContent.texts[ptag].x
			local y1 = nodesContent.texts[ptag].y
			local x2 = tasksContent.texts[self.ttag].x
			local y2 = tasksContent.texts[self.ttag].y
			content:add("ae" .. ptag, "line", { x1 = x1, y1 = y1, x2 = x2, y2 = y2, s = "dot" })
			content:add("av" .. ptag, "text", {
				x = (x1 + x2) / 2,
				y = (y1 + y2) / 2,
				t = node.atag,
				bc = "surface",
			})
		end
	end

	content:add("dbackground", "rect", { x = W * rw, y = 0, w = W * (1 - rw), h = H, sc = "background" })
	content:draw(self.colors, self.font)

	if self.ntag then
		self.drawable:setf(inspect(graph.nodes[self.ntag].data), W * rw, "left")
		local x, y = W * rw, 0
		local w, h = self.drawable:getDimensions()
		if h > H then
			local rate = (mouseY - y) / H
			local offset = math.max(0, h - H) * rate
			y = y - offset
		end
		love.graphics.setColor(node.dirty and self.colors.warning or self.colors.success)
		love.graphics.draw(self.drawable, x, y)
	end
end

setmetatable(drawGraph, {
	__call = function(self, graph)
		love.graphics.push("all")
		love.graphics.setFont(self.font)
		drawGraph:call(graph)
		love.graphics.pop()
	end,
})

drawGraph:setFont(love.graphics.newFont(12))

return drawGraph
