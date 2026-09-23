local softlove = {
	drawGraph = require("softlove.drawGraph"),
	devices = require("softlove.devices"),
	assets = require("softlove.assets"),
	ui = require("softlove.ui"),
	locales = require("softlove.locales"),
	window = require("softlove.window"),
	ntags = require("softlove.ntags"),
}

local function union(self, other)
	for k, v in pairs(other) do
		assert(self[k] == nil)
		self[k] = v
	end
end

function softlove.getNodes()
	local nodes = {
		window = {
			tasks = {
				update = {
					func = softlove.window.update,
				},
			},
			apis = {
				update = { ttag = "update" },
			},
		},
		locales = {
			tasks = {
				init = {
					func = function(self)
						softlove.locales.init(self)
						union(self, softlove.locales.read)
					end,
				},
			},
			apis = {
				add = {
					func = softlove.locales.write.add,
					atag = "writable",
				},
				del = {
					func = softlove.locales.write.del,
					atag = "writable",
				},
				setCurrent = {
					func = softlove.locales.write.setCurrent,
					atag = "writable",
				},
			},
		},
	}
	return nodes
end

function softlove.getCallbacksWindow(node)
	-- love.displayrotated = function(displayindex, orientation) end
	return {
		focus = node.apis.update,
		visible = node.apis.update,
		resize = node.apis.update,
	}
end

return softlove
