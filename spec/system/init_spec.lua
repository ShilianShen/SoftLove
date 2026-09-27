package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local system = require("softlove.system")
local Locales = require("softlove.system.Locales")
local Window = require("softlove.system.Window")

describe("system", function()
	describe("getNodes", function()
		local nodes

		before_each(function()
			nodes = system.getNodes()
		end)

		it("should define the window tasks", function()
			assert.equals(Window.init, nodes.window.tasks.init.func)
			assert.equals(Window.update, nodes.window.tasks.update.func)
			assert.same({ "init" }, nodes.window.tasks.update.parents_c)
		end)

		it("should initialize locales and expose translate", function()
			local ctx = {}

			nodes.locales.tasks.init.func(ctx)

			assert.same({}, ctx.translator)
			assert.is_false(ctx.current)
			assert.equals(Locales.translate, ctx.translate)
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
				end
			end
		end)
	end)

	describe("getCallbacks", function()
		it("should map LOVE window callbacks to node APIs", function()
			local nodes = system.getNodes()

			assert.same({
				focus = nodes.window.apis.focus,
				resize = nodes.window.apis.resize,
				visible = nodes.window.apis.visible,
			}, system.getCallbacks(nodes))
		end)
	end)
end)
