local Content = {}
local style = require("src.softlove.tools.drawGraph.style")

local function lineCount(str)
	if str == "" then
		return 0
	end

	local _, count = str:gsub("\n", "\n")
	return count + 1
end

local function getDist(parents, order)
	local depth = {}
	for _, vtag in ipairs(order) do
		depth[vtag] = 1
		for ptag, _ in pairs(parents[vtag]) do
			depth[vtag] = math.max(depth[vtag], depth[ptag] + 1)
		end
	end

	local dist = {}
	for vtag, d in pairs(depth) do
		dist[d] = dist[d] or {}
		table.insert(dist[d], vtag)
	end

	for d = 1, #dist do
		table.sort(dist[d])
	end

	return dist
end

function Content.newVertex(x, y, t)
	return {
		x = x,
		y = y,
		surfaceColor = "surface",
		borderColor = "border",
		textColor = "text",
		text = t,
	}
end

function Content.newEdge(x1, y1, x2, y2)
	return {
		x1 = x1,
		y1 = y1,
		x2 = x2,
		y2 = y2,
		surfaceColor = "surface",
		borderColor = "border",
		textColor = "text",
		text = "",
		style = "line",
	}
end

local function _newContent(vertices, parents, children, order, X, Y, W, H)
	local content = {}
	local dist = getDist(parents, order)

	content.title = ""
	content.titleColor = "text"
	content.borderColor = "border"
	content.x = X
	content.y = Y
	content.w = W
	content.h = H

	content.vertices = {}
	local D = #dist
	for j = 1, D do
		local B = #dist[j]
		for i = 1, B do
			local vtag = dist[j][i]
			local x = X + W / B * (i - 0.5)
			local y = Y + H / D * (j - 0.5)
			content.vertices[vtag] = Content.newVertex(x, y, vtag)
		end
	end

	content.edges = {}
	for vtag, _ in pairs(vertices) do
		local x1 = content.vertices[vtag].x
		local y1 = content.vertices[vtag].y
		for ctag, _ in pairs(children[vtag]) do
			local x2 = content.vertices[ctag].x
			local y2 = content.vertices[ctag].y
			local edge = Content.newEdge(x1, y1, x2, y2)
			table.insert(content.edges, edge)
		end
	end

	return content
end

local function drawContent(content, theme, font)
	do
		love.graphics.setColor(theme.colors[content.borderColor])
		love.graphics.rectangle("line", content.x + 1, content.y + 1, content.w - 2, content.h - 2)

		local w = font:getWidth(content.title or "")
		love.graphics.setColor(theme.colors[content.titleColor])
		love.graphics.print(content.title or "", content.x + (content.w - w) / 2, content.y)
	end

	for _, edge in ipairs(content.edges) do
		local w = font:getWidth(edge.text or "")
		local h = font:getHeight() * lineCount(edge.text or "")
		local x = (edge.x1 + edge.x2 - w) / 2
		local y = (edge.y1 + edge.y2 - h) / 2
		love.graphics.setColor(theme.colors[edge.borderColor])
		style[edge.style](edge.x1, edge.y1, edge.x2, edge.y2)
		love.graphics.setColor(theme.colors[edge.surfaceColor])
		love.graphics.rectangle("fill", x, y, w, h)
		love.graphics.setColor(theme.colors[edge.textColor])
		love.graphics.print(edge.text or "", font, x, y)
	end

	for _, vertex in pairs(content.vertices) do
		local w = font:getWidth(vertex.text or "")
		local h = font:getHeight() * lineCount(vertex.text or "")
		local x = vertex.x - w / 2
		local y = vertex.y - h / 2
		love.graphics.setColor(theme.colors[vertex.surfaceColor])
		love.graphics.rectangle("fill", x - 1, y - 1, w + 2, h + 2)
		love.graphics.setColor(theme.colors[vertex.borderColor])
		love.graphics.rectangle("line", x - 1, y - 1, w + 2, h + 2)
		love.graphics.setColor(theme.colors[vertex.textColor])
		love.graphics.print(vertex.text or "", font, x, y)
	end
end

function Content.newContent(...)
	local content = _newContent(...)
	content.draw = drawContent
	return content
end

return Content
