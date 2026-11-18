package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local system = require("softlove.system")
local Locales = require("softlove.system.Locales")
local Window = require("softlove.system.Window")

describe("system", function()
	describe("node factories", function()
		local nodes

		before_each(function()
			nodes = { window = system.Window(), locales = system.Locales() }
		end)

		it("should define the window tasks", function()
			assert.equals(Window.init, nodes.window.tasks.init.func)
			assert.equals(Window.update, nodes.window.tasks.update.func)
			assert.same({ "init" }, nodes.window.tasks.update.parents_c)
			assert.is_false(nodes.window.tasks.init.back)
			assert.is_false(nodes.window.tasks.update.back)
			assert.equals("writable", nodes.window.tasks.init.atag)
			assert.equals("writable", nodes.window.tasks.update.atag)
			assert.equals("readonly", nodes.window.atag)
		end)

		it("should initialize locales and expose translate", function()
			local ctx = {}

			nodes.locales.tasks.init.func(ctx)

			assert.same({}, ctx.translator)
			assert.is_false(ctx.current)
			assert.equals(Locales.translate, ctx.translate)
			assert.is_false(nodes.locales.tasks.init.back)
			assert.equals("writable", nodes.locales.tasks.init.atag)
			assert.equals("readonly", nodes.locales.atag)
		end)

		it("should bind system APIs as writable operations", function()
			local expected = {
				window = {
					focus = Window.focus,
					visible = Window.visible,
					resize = Window.resize,
				},
				locales = {
					add = Locales.add,
					del = Locales.del,
					setCurrent = Locales.setCurrent,
				},
			}

			for nodeName, apis in pairs(expected) do
				for apiName, func in pairs(apis) do
					assert.equals(func, nodes[nodeName].apis[apiName].func)
					assert.equals("writable", nodes[nodeName].apis[apiName].atag)
					assert.is_true(nodes[nodeName].apis[apiName].dirty)
				end
			end
		end)
	end)
end)
