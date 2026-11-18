local util = {}

---Shallowly select the first non-nil value for each field from left to right, preserving false and 0; do not merge or copy field values.
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

---Expand an acyclic table structure into an independent tree: copy table keys and values recursively, splitting repeated references.
---Metatables are not copied; non-table values such as functions and userdata pass through, leaving closure and LÖVE resource state shared.
---Detect cycles only along the current recursion path, allowing shared source tables across branches; report cycles with their paths.
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
