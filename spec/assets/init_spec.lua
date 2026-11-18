package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local assets = require("softlove.assets")
local Locales = require("softlove.assets.Locales")

describe("assets", function()
	describe("Locales", function()
		local node

		before_each(function()
			node = assets.Locales()
		end)

		it("should initialize locales and expose translate", function()
			local ctx = {}
			node.tasks.init.func(ctx)

			assert.same({}, ctx.translator)
			assert.is_false(ctx.current)
			assert.equals(Locales.translate, ctx.translate)
			assert.equals("hello", ctx:translate("hello"))
			assert.is_false(node.tasks.init.back)
			assert.equals("writable", node.tasks.init.atag)
			assert.equals("readonly", node.atag)
		end)

		it("should bind locale APIs as writable operations", function()
			local expected = {
				add = Locales.add,
				del = Locales.del,
				setCurrent = Locales.setCurrent,
			}

			for apiName, func in pairs(expected) do
				assert.equals(func, node.apis[apiName].func)
				assert.equals("writable", node.apis[apiName].atag)
				assert.is_true(node.apis[apiName].dirty)
			end
		end)
	end)
end)
