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

--- @param data table  
--- @param columns table? 
--- @param rows table? 
--- @return string
local function formatTable(data, columns, rows)
    assert(type(data) == "table", "data must be a table")

    local row_indices = {}
    if rows == nil then
        for i = 1, #data do
            row_indices[#row_indices + 1] = i
        end
    else
        for _, r in ipairs(rows) do
            row_indices[#row_indices + 1] = r
        end
    end

    local col_names = {}
    if columns == nil then
        local seen = {}
        for _, r in ipairs(row_indices) do
            local dict = data[r]
            if type(dict) == "table" then
                for k in pairs(dict) do
                    if not seen[k] then
                        seen[k] = true
                        col_names[#col_names + 1] = k
                    end
                end
            end
        end
        pcall(table.sort, col_names, function(a, b)
            return tostring(a) < tostring(b)
        end)
    else
        for _, c in ipairs(columns) do
            col_names[#col_names + 1] = c
        end
    end

    local grid = {}
    local header = { "#" }
    for _, c in ipairs(col_names) do
        header[#header + 1] = tostring(c)
    end
    grid[#grid + 1] = header

    for _, r in ipairs(row_indices) do
        local dict = data[r]
        local row = { tostring(r) }
        for _, c in ipairs(col_names) do
            local v = type(dict) == "table" and dict[c] or nil
            row[#row + 1] = v == nil and "" or tostring(v)
        end
        grid[#grid + 1] = row
    end

    local num_cols = #header
    local widths = {}
    for i = 1, num_cols do widths[i] = 0 end
    for _, row in ipairs(grid) do
        for i = 1, num_cols do
            local w = #(row[i] or "")
            if w > widths[i] then widths[i] = w end
        end
    end

    local lines = {}
    for _, row in ipairs(grid) do
        local parts = {}
        for i = 1, num_cols do
            local s = row[i] or ""
            if i == num_cols then
                parts[i] = s
            else
                parts[i] = s .. string.rep(" ", widths[i] - #s)
            end
        end
        lines[#lines + 1] = table.concat(parts, " ")
    end

    return table.concat(lines, "\n")
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
    local tab = formatTable(self.order, {"ntag", "ttag", "mu", "sigma"})
    local head = (tab:match("^(.-)\r?\n") or tab)

    local text = love.graphics.newText(font, tab)
	local winW, winH = love.graphics.getDimensions()
    local tabW, tabH = text:getDimensions()
    local _, mouseY = love.mouse.getPosition()
    local tabX = (winW - tabW) / 2
    local tabY = (winH - tabH) / 2
    if tabH > winH then
        tabY = (winH - tabH) * mouseY / winH
    end
    local headX = math.max(tabX, 0)
    local headY = math.max(tabY, 0)

	love.graphics.setColor(theme.background)
	love.graphics.rectangle("fill", tabX - 1, tabY - 1, tabW + 2, tabH + 2)

	love.graphics.setColor(theme.border)
	love.graphics.rectangle("line", tabX, tabY, tabW, tabH)

	love.graphics.setColor(theme.text)
    love.graphics.draw(text, tabX, tabY)

    love.graphics.setColor(theme.background)
    love.graphics.rectangle("fill", headX, headY, tabW, font:getHeight())

    love.graphics.setColor(theme.text)
    love.graphics.print(head, font, headX, headY)
end

return TimeProfiler
