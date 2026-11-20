local Content = require("softlove.util.drawGraph.Content")
local getDAG = require("softlove.util.drawGraph.getDAG")
local inspect = require("softlove.inspect")

local drawGraph = {
	ntag = nil,
	ttag = nil,
	defaultNode = { tasks = {}, parents_c = {}, children_c = {}, order_c = {} },
}

drawGraph.theme = {
	background = { 0.025, 0.025, 0.025, 0.7 },

	point = { 0.90, 0.35, 0.25 },
	text = { 0.88, 0.88, 0.84 },
	border = { 0.72, 0.72, 0.68 },
	surface = { 0.055, 0.055, 0.050 },

	accent_border = { 0.72, 0.58, 0.12 },
	accent_surface = { 0.12, 0.10, 0.04 },

	warning = { 0.95, 0.40, 0.18 },
	success = { 0.40, 0.85, 0.45 },
}
drawGraph.font = love.graphics.newFont(12)
drawGraph.drawable = love.graphics.newText(drawGraph.font)

local function tableDepth(value, visiting)
	if type(value) ~= "table" then
		return 0
	end

	visiting = visiting or {}
	if visiting[value] then
		return 0
	end
	visiting[value] = true

	local depth = 1
	-- Match inspect's raw traversal of table keys, values and visible metatables.
	for key, child in next, value do
		depth = math.max(depth, 1 + tableDepth(key, visiting), 1 + tableDepth(child, visiting))
	end
	depth = math.max(depth, 1 + tableDepth(getmetatable(value), visiting))

	visiting[value] = nil
	return depth
end

---@param graph softdep.Graph
---@param theme table|nil
---@param font love.Font|nil
return function(graph, theme, font)
	love.graphics.push("all")
	local rw = 0.6
	local rh = 0.6
	local W, H = love.graphics.getDimensions()
	local mouseX, mouseY = love.mouse.getPosition()
	theme = theme or drawGraph.theme
	font = font or drawGraph.font

	local nodesContent =
		getDAG(graph.nodes, graph.parents_n, graph.children_n, graph.order_n, drawGraph.ntag, 0, 0, W * rw, H * rh)

	for ntag, text in pairs(nodesContent.texts) do
		local x = text.x
		local y = text.y
		local w = font:getWidth(text.t)
		local h = font:getHeight()
		if mouseX >= x - w / 2 and mouseX <= x + w / 2 and mouseY >= y - h / 2 and mouseY <= y + h / 2 then
			drawGraph.ntag = ntag
			drawGraph.ttag = nil
			break
		end
	end

	local node = drawGraph.ntag and graph.nodes[drawGraph.ntag] or drawGraph.defaultNode
	local tasksContent = getDAG(
		node.tasks,
		node.parents_c,
		node.children_c,
		node.order_c,
		drawGraph.ttag,
		0,
		H * rh,
		W * rw,
		H * (1 - rh)
	)

	for ttag, text in pairs(tasksContent.texts) do
		local x = text.x
		local y = text.y
		local w = font:getWidth(text.t)
		local h = font:getHeight()
		if mouseX >= x - w / 2 and mouseX <= x + w / 2 and mouseY >= y - h / 2 and mouseY <= y + h / 2 then
			drawGraph.ttag = ttag
			break
		end
	end

	local content = Content.union({ n = nodesContent, t = tasksContent })

	if drawGraph.ntag and drawGraph.ttag then
		for _, ptag in pairs(graph.parents_d[drawGraph.ntag][drawGraph.ttag]) do
			local pnode = graph.nodes[ptag]
			local x1 = nodesContent.texts[ptag].x
			local y1 = nodesContent.texts[ptag].y
			local x2 = tasksContent.texts[drawGraph.ttag].x
			local y2 = tasksContent.texts[drawGraph.ttag].y
			content:add("ae" .. ptag, "line", { x1 = x1, y1 = y1, x2 = x2, y2 = y2, s = "dot" })
			content:add("av" .. ptag, "text", {
				x = (x1 + x2) / 2,
				y = (y1 + y2) / 2,
				t = pnode.atag,
				bc = "surface",
			})
		end
	end

	content:add("dbackground", "rect", { x = W * rw, y = 0, w = W * (1 - rw), h = H, sc = "background" })
	content:draw(theme, font)

	if drawGraph.ntag then
		local x, y = W * rw, 0
		local w = W * (1 - rw)
		local D = tableDepth(node.data)

		local depth = 1 + (D - 1) * (mouseX - x) / w
		if depth < 1 then
			depth = 1
		elseif depth > D then
			depth = D
		else
			depth = math.floor(depth + 0.5)
		end

		if not drawGraph.ttag then
			drawGraph.drawable:setf(inspect(node.data, { indent = "    ", depth = depth }), W * (1 - rw), "left")
		else
			drawGraph.drawable:setf(inspect(node.tasks[drawGraph.ttag], { indent = "    " }), W * (1 - rw), "left")
		end
		drawGraph.drawable:setFont(font)

		local h = drawGraph.drawable:getHeight()
		if h > H then
			local rate = (mouseY - y) / H
			local offset = math.max(0, h - H) * rate
			y = y - offset
		end

		love.graphics.setColor(node.dirty and theme.warning or theme.success)
		love.graphics.draw(drawGraph.drawable, x, y)
	end
	love.graphics.pop()
end
