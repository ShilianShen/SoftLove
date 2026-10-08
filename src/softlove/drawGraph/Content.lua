local style = require("softlove.drawGraph.style")

---@param tbl table<string, any>
---@return fun(): string?, any
local function sortedPairs(tbl)
	local keys = {}

	for key in pairs(tbl) do
		keys[#keys + 1] = key
	end

	table.sort(keys)

	local index = 0

	return function()
		index = index + 1

		local key = keys[index]
		if key ~= nil then
			return key, tbl[key]
		end
	end
end

---@class softlove.drawGraph.Point
---@field x number
---@field y number
---@field c string
---@field w number

---@class softlove.drawGraph.Line
---@field x1 number
---@field y1 number
---@field x2 number
---@field y2 number
---@field c string
---@field w number
---@field s string

---@class softlove.drawGraph.Rect
---@field x number
---@field y number
---@field w number
---@field h number
---@field sc string
---@field bc string

---@class softlove.drawGraph.Text
---@field x number
---@field y number
---@field t string
---@field tc string
---@field sc string
---@field bc string

---@class softlove.drawGraph.Content
---@field points table<string, softlove.drawGraph.Point>
---@field lines table<string, softlove.drawGraph.Line>
---@field rects table<string, softlove.drawGraph.Rect>
---@field texts table<string, softlove.drawGraph.Text>
local Content = {}

---@return softlove.drawGraph.Content
function Content.new()
	return {
		points = {},
		lines = {},
		rects = {},
		texts = {},

		clean = Content.clean,
		add = Content.add,
		draw = Content.draw,
	}
end

function Content:clean()
	self.points = {}
	self.lines = {}
	self.rects = {}
end

---@param key any
---@param shape "point"|"line"|"rect"|"text"
---@param args table<any>
function Content:add(key, shape, args)
	if shape == "point" then
		self.points[key] = {
			x = args.x or 0,
			y = args.y or 0,
			c = args.c or "point",
			w = args.w or 1,
		}
	elseif shape == "line" then
		self.lines[key] = {
			x1 = args.x1 or 0,
			y1 = args.y1 or 0,
			x2 = args.x2 or 1,
			y2 = args.y2 or 1,
			c = args.c or "border",
			w = args.w or 1,
			s = args.s or "line",
		}
	elseif shape == "rect" then
		self.rects[key] = {
			x = args.x or 0,
			y = args.y or 0,
			w = args.w or 1,
			h = args.h or 1,
			sc = args.sc or "surface",
			bc = args.bc or "border",
		}
	elseif shape == "text" then
		self.texts[key] = {
			x = args.x or 0,
			y = args.y or 0,
			t = args.t or "",
			tc = args.tc or "text",
			sc = args.sc or "surface",
			bc = args.bc or "border",
		}
	end
end

---@param theme table<any>
---@param font love.Font|nil
function Content:draw(theme, font)
	font = font or love.graphics.getFont()
	love.graphics.setFont(font)

	for _, rect in sortedPairs(self.rects) do
		love.graphics.setColor(theme[rect.sc])
		love.graphics.rectangle("fill", rect.x, rect.y, rect.w, rect.h)

		love.graphics.setColor(theme[rect.bc])
		love.graphics.rectangle("line", rect.x + 1, rect.y + 1, rect.w - 2, rect.h - 2)
	end

	for _, line in sortedPairs(self.lines) do
		love.graphics.setColor(theme[line.c])
		style[line.s](line.x1, line.y1, line.x2, line.y2)
	end

	for _, point in sortedPairs(self.points) do
		love.graphics.setColor(theme[point.c])
		love.graphics.rectangle("fill", point.x - point.w / 2, point.y - point.w / 2, point.w, point.w)
	end

	for _, text in sortedPairs(self.texts) do
		local w = font:getWidth(text.t)
		local h = font:getHeight()
		local x = text.x - w / 2
		local y = text.y - h / 2

		love.graphics.setColor(theme[text.sc])
		love.graphics.rectangle("fill", x - 1, y - 1, w + 2, h + 2)

		love.graphics.setColor(theme[text.bc])
		love.graphics.rectangle("line", x, y, w, h)

		love.graphics.setColor(theme[text.tc])
		love.graphics.print(text.t, x, y)
	end
end

---@return softlove.drawGraph.Content
function Content.union(pcs)
	local result = Content.new()

	for prefix, content in pairs(pcs) do
		for _, key in ipairs({ "lines", "points", "rects", "texts" }) do
			for k, v in pairs(content[key]) do
				result[key][prefix .. k] = v
			end
		end
	end

	return result
end

return Content
