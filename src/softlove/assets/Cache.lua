local Cache = {}

local function getArrKey(...)
	local arr = { ... }
	local parts = {}

	for i = 1, #arr do
		local v = arr[i]
		local kind = type(v)

		if kind == "string" then
			parts[#parts + 1] = "s" .. #v .. ":" .. v
		elseif kind == "number" then
			if v == 0 then
				v = 0
			end
			parts[#parts + 1] = "n" .. string.format("%.17g", v)
		elseif kind == "boolean" then
			parts[#parts + 1] = v and "b1" or "b0"
		else
			error("unsupported value type: " .. kind)
		end
	end

	return "a" .. #arr .. ":" .. table.concat(parts, "|")
end

function Cache:init()
	self.data = {}
end

function Cache:setMethod(method, func)
	self[method] = function(...)
		local key = getArrKey(method, ...)
		if self.data[key] == nil then
			local obj = func(...)
			if self.check == nil or self:check(obj) then
				self.data[key] = obj
			end
		end
		return self.data[key]
	end
end

return Cache
