local util = {}

function util.patch(...)
	local args = { ... }
	local result = {}

	for _, arg in ipairs(args) do
		for k, v in pairs(arg) do
			if result[k] == nil then
				result[k] = v
			end
		end
	end

	return result
end

function util.deepcopyDAGToTree(root)
	local in_progress = {}

	local function _deepcopyDAGToTree(v, path)
		if type(v) ~= "table" then
			return v
		end

		if in_progress[v] then
			error("deepcopyDAGToTree: cycle detected at " .. path, 0)
		end

		in_progress[v] = true
		local r = {}

		for k, val in pairs(v) do
			local kk = _deepcopyDAGToTree(k, path .. "[key]")
			r[kk] = _deepcopyDAGToTree(val, path .. "[" .. tostring(k) .. "]")
		end

		in_progress[v] = nil
		return r
	end

	return _deepcopyDAGToTree(root, "root")
end

function util.pass() end

return util
