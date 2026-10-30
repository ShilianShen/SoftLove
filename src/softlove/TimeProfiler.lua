local inspect = require("src.softlove.inspect")

---@class softlove.TimeProfiler.Metadata
---@field sum_dt number
---@field sum_dt2 number
---@field n integer
---@field N integer
---@field mu number
---@field sigma number
---@field ntag string
---@field ttag string

---@class softlove.TimeProfiler
---@field graph softdep.Graph
---@field data table<string, table<string, softlove.TimeProfiler.Metadata>>
---@field order softlove.TimeProfiler.Metadata[]
local TimeProfiler = {}

---@param graph softdep.Graph
---@return softlove.TimeProfiler
function TimeProfiler.new(graph)
	local profiler = {
		graph = graph,
		data = {},
		order = {},
	}
	for k, v in pairs(TimeProfiler) do
		profiler[k] = v
	end
	return profiler
end

function TimeProfiler:update()
	self.order = {}
	for ntag, node in pairs(self.graph.nodes) do
		self.data[ntag] = self.data[ntag] or {}
		for ttag, task in pairs(node.tasks) do
			self.data[ntag][ttag] = self.data[ntag][ttag]
				or {
					sum_dt = 0,
					sum_dt2 = 0,
					n = 0,
					N = 0,
					ntag = ntag,
					ttag = ttag,
				}
			local metadata = self.data[ntag][ttag]
			if metadata.N ~= task.count then
				metadata.sum_dt = metadata.sum_dt + task.dt
				metadata.sum_dt2 = metadata.sum_dt2 + task.dt * task.dt
				metadata.n = metadata.n + 1

				metadata.mu = metadata.sum_dt / metadata.n
				metadata.sigma = math.sqrt(metadata.sum_dt2 / metadata.n - metadata.mu * metadata.mu)

				metadata.N = task.count
			end
			self.order[#self.order + 1] = metadata
		end
	end
	table.sort(self.order, self.comp)
end

---@param a softlove.TimeProfiler.Metadata
---@param b softlove.TimeProfiler.Metadata
---@return boolean
function TimeProfiler.comp(a, b)
	if a.mu ~= b.mu then
		return a.mu > b.mu
	end
	if a.sigma ~= b.sigma then
		return a.sigma > b.sigma
	end
	if a.ntag ~= b.ntag then
		return a.ntag < b.ntag
	end
	if a.ttag ~= b.ttag then
		return a.ttag < b.ttag
	end
	return false
end

function TimeProfiler:draw(theme, font)
	local winW, winH = love.graphics.getDimensions()

	love.graphics.setColor(theme.background)
	love.graphics.rectangle("fill", 0, 0, winW, winH)

	love.graphics.setColor(theme.border)
	love.graphics.rectangle("line", 0, 0, winW, winH)

	love.graphics.setFont(font)
	love.graphics.setColor(theme.text)
	local y = 0
	for i, metadata in ipairs(self.order) do
		love.graphics.print(i, 0, y)
		love.graphics.print(metadata.ntag, winW / 5, y)
		love.graphics.print(metadata.ttag, winW / 5 * 2, y)
		love.graphics.print(metadata.mu, winW / 5 * 3, y)
		love.graphics.print(metadata.sigma, winW / 5 * 4, y)
		y = y + font:getHeight()
	end
end

return TimeProfiler
