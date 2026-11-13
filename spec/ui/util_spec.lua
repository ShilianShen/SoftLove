package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local util = require("softlove.ui.util")

describe("UI copying utilities", function()
	it("should preserve false and zero when applying patches", function()
		assert.same(
			{ visible = false, w = 0, h = 20 },
			util.patch({ visible = false, w = 0 }, { visible = true, w = 100, h = 20 })
		)
	end)

	it("should expand shared tables into independently writable branches", function()
		local shared = { state = { value = 1 } }
		local copy = util.deepcopyDAGToTree({ first = shared, second = shared })
		assert.is_not.equal(shared, copy.first)
		assert.is_not.equal(copy.first, copy.second)
		copy.first.state.value = 2
		assert.equals(1, copy.second.state.value)
		assert.equals(1, shared.state.value)
	end)

	it("should copy table keys without retaining source references", function()
		local key = { id = 1 }
		local source = { [key] = { value = 2 } }
		local copy = util.deepcopyDAGToTree(source)
		local copiedKey, copiedValue = next(copy)
		assert.same(key, copiedKey)
		assert.is_not.equal(key, copiedKey)
		copiedKey.id = 3
		copiedValue.value = 4
		assert.equals(1, key.id)
		assert.equals(2, source[key].value)
	end)

	it("should reject direct cycles with their location", function()
		local source = {}
		source.self = source
		assert.has_error(function()
			util.deepcopyDAGToTree(source)
		end, "deepcopyDAGToTree: cycle detected at root[self]")
	end)

	it("should reject indirect cycles instead of recursing indefinitely", function()
		local source = { child = {} }
		source.child.parent = source
		assert.has_error(function()
			util.deepcopyDAGToTree(source)
		end, "deepcopyDAGToTree: cycle detected at root[child][parent]")
	end)

	it("should reject cycles through table keys", function()
		local source = {}
		source[source] = true
		assert.has_error(function()
			util.deepcopyDAGToTree(source)
		end, "deepcopyDAGToTree: cycle detected at root[key]")
	end)
end)
