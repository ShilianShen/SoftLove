local input = require("softlove.input")
local system = require("softlove.system")
local softlove = {
	util = require("softlove.util"),
	ui = require("softlove.ui"),
	input = require("softlove.input"),
	system = require("softlove.system"),
	assets = require("softlove.assets"),
}

local function union(...)
	local args = { ... }
	local result = {}
	for _, arg in ipairs(args) do
		for k, v in pairs(arg) do
			assert(result[k] == nil)
			result[k] = v
		end
	end
	return result
end

function softlove.getNodes()
	return union(system.getNodes(), input.getNodes())
end

function softlove.setCallbacks(nodes)
	local callbacks = union(system.getCallbacks(nodes), input.getCallbacks(nodes))
	for k, v in pairs(callbacks) do
		love[k] = v
	end
end

return softlove
