package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local system = require("softlove.system")
local Window = require("softlove.system.Window")

describe("system", function()
	describe("node factories", function()
		local nodes

		before_each(function()
			nodes = { window = system.Window() }
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

		it("should bind system APIs as writable operations", function()
			local expected = {
				window = {
					focus = Window.focus,
					visible = Window.visible,
					resize = Window.resize,
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
