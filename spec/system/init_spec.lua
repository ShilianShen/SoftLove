package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local system = require("softlove.system")

describe("softlove", function()
	it("loads without errors", function()
		assert.is_truthy(system)
	end)
end)
