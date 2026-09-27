package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local input = require("softlove.input")
local system = require("softlove.system")
local originalLove = _G.love
_G.love = {
	graphics = {
		line = function() end,
		newFont = function()
			return {}
		end,
	},
}
local softlove = require("softlove")
_G.love = originalLove

describe("softlove", function()
	describe("getNodes", function()
		it("should combine system and input nodes", function()
			local nodes = softlove.getNodes()
			local names = {}

			for name, node in pairs(nodes) do
				names[name] = true
				assert.is_table(node)
			end
			assert.same({
				joysticks = true,
				keyboard = true,
				locales = true,
				mouse = true,
				wheel = true,
				window = true,
			}, names)
		end)

		it("should return fresh node tables", function()
			local first = softlove.getNodes()
			local second = softlove.getNodes()

			assert.not_equals(first, second)
			assert.not_equals(first.window, second.window)
			assert.not_equals(first.mouse, second.mouse)
		end)
	end)

	describe("setCallbacks", function()
		local previousLove

		before_each(function()
			previousLove = _G.love
			_G.love = { untouched = true }
		end)

		after_each(function()
			_G.love = previousLove
		end)

		it("should install all system and input callbacks on LOVE", function()
			local nodes = softlove.getNodes()
			local expected = system.getCallbacks(nodes)
			for name, callback in pairs(input.getCallbacks(nodes)) do
				expected[name] = callback
			end

			softlove.setCallbacks(nodes)

			for name, callback in pairs(expected) do
				assert.equals(callback, _G.love[name])
			end
			assert.is_true(_G.love.untouched)
		end)
	end)
end)
