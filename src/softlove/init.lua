local input = require("softlove.input")
local system = require("softlove.system")
local assets = require("softlove.assets")
local softlove = {
	drawGraph = require("softlove.drawGraph"),
	ui = require("softlove.ui"),
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
	return union(system.getNodes(), assets.getNodes()) -- TODO: add input nodes
end

function softlove.setCallbacks(nodes)
	local callbacks = union(system.getCallbacks(nodes)) -- TODO: add input callbacks
	for k, v in pairs(callbacks) do
		love[k] = v
	end
end

return softlove
