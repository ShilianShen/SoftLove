package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local input = require("softlove.input")

describe("softlove", function()
	it("loads without errors", function()
		assert.is_truthy(input)
	end)
end)
