package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local input = require("softlove.input")
local Joysticks = require("softlove.input.Joysticks")
local Keyboard = require("softlove.input.Keyboard")
local Mouse = require("softlove.input.Mouse")
local Wheel = require("softlove.input.Wheel")

describe("input", function()
	describe("node factories", function()
		local nodes

		before_each(function()
			nodes = {
				joysticks = input.Joysticks(),
				keyboard = input.Keyboard(),
				mouse = input.Mouse(),
				wheel = input.Wheel(),
			}
		end)

		it("should define state tasks for every input node", function()
			local modules = {
				joysticks = Joysticks,
				keyboard = Keyboard,
				mouse = Mouse,
				wheel = Wheel,
			}

			for name, module in pairs(modules) do
				local tasks = nodes[name].tasks
				assert.equals(module.init, tasks.init.func)
				assert.equals(module.step, tasks.step.func)
				assert.same({ "init" }, tasks.step.parents_c)
				assert.is_nil(tasks.step.auto)
				assert.is_false(tasks.init.back)
				assert.is_true(tasks.step.back)
				assert.equals("writable", tasks.init.atag)
				assert.equals("writable", tasks.step.atag)
				assert.equals("readonly", nodes[name].atag)
			end
		end)

		it("should bind input APIs as writable operations", function()
			local expected = {
				joysticks = {
					added = Joysticks.added,
					removed = Joysticks.removed,
					pressed = Joysticks.pressed,
					released = Joysticks.released,
					axis = Joysticks.axis,
					hat = Joysticks.hat,
					gamepadpressed = Joysticks.gamepadpressed,
					gamepadreleased = Joysticks.gamepadreleased,
					gamepadaxis = Joysticks.gamepadaxis,
				},
				mouse = {
					moved = Mouse.moved,
					pressed = Mouse.pressed,
					released = Mouse.released,
					focus = Mouse.focus,
				},
				keyboard = {
					pressed = Keyboard.pressed,
					released = Keyboard.released,
				},
				wheel = { moved = Wheel.moved },
			}

			for nodeName, apis in pairs(expected) do
				for apiName, func in pairs(apis) do
					assert.equals(func, nodes[nodeName].apis[apiName].func)
					assert.equals("writable", nodes[nodeName].apis[apiName].atag)
					assert.is_true(nodes[nodeName].apis[apiName].dirty)
				end
			end

			for _, apiName in ipairs({ "gamepadpressed", "gamepadreleased", "gamepadaxis" }) do
				assert.is_table(nodes.joysticks.apis[apiName])
				assert.equals("writable", nodes.joysticks.apis[apiName].atag)
			end
		end)
	end)
end)
