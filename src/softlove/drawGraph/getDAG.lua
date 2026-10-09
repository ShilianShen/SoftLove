local Content = require("softlove.drawGraph.Content")

---@param parents softdep.AdjList
---@param order string[]
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

---@param vertices table<string, softdep.Node>
---@param parents softdep.AdjList
---@param children softdep.AdjList
---@param order string[]
---@param target string
---@param X number
---@param Y number
---@param W number
---@param H number
local function getDAG(vertices, parents, children, order, target, X, Y, W, H)
	X = X or 0
	Y = Y or 0
	W = W or love.graphics.getWidth()
	H = H or love.graphics.getHeight()
	local content = Content.new()
	local dist = getDist(parents, order)
	local D = #dist

	content:add("background", "rect", { x = X, y = Y, w = W, h = H, sc = "background" })

	for j = 1, D do
		local B = #dist[j]
		for i = 1, B do
			local vtag = dist[j][i]
			local vertex = vertices[vtag]
			local x = X + W / B * (i - 0.5)
			local y = Y + H / D * (j - 0.5)
			content:add(vtag, "text", {
				x = x,
				y = y,
				t = vtag,
				tc = vertex.dirty and "warning" or "success",
				sc = target == vtag and "accent_surface" or nil,
				bc = target == vtag and "accent_border" or nil,
			})
		end
	end

	local count = 1
	for vtag, _ in pairs(parents) do
		local x1 = content.texts[vtag].x
		local y1 = content.texts[vtag].y
		for ctag, _ in pairs(children[vtag]) do
			local x2 = content.texts[ctag].x
			local y2 = content.texts[ctag].y
			content:add("e" .. count, "line", { x1 = x1, y1 = y1, x2 = x2, y2 = y2 })
			count = count + 1
		end
	end

	return content
end

return getDAG
