local input = require("softlove.input")
local system = require("softlove.system")
local softlove = {
	drawGraph = require("softlove.drawGraph"),
	assets = require("softlove.assets"),
	ui = require("softlove.ui"),
}

local function union(self, other)
	for k, v in pairs(other) do
		assert(self[k] == nil)
		self[k] = v
	end
end

function softlove.getNodes()
	local nodes = {}
	union(nodes, system.getNodes())
	union(nodes, input.getNodes())
	return nodes
end

function softlove.setCallbacks(nodes)
	local callbacks = {}
	union(callbacks, system.getCallbacks(nodes))
	union(callbacks, input.getCallbacks(nodes))
	for k, v in pairs(callbacks) do
		love[k] = v
	end
end

return softlove
