package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local input = require("softlove.input")
local Joysticks = require("softlove.input.Joysticks")
local Keyboard = require("softlove.input.Keyboard")
local Mouse = require("softlove.input.Mouse")
local Wheel = require("softlove.input.Wheel")

describe("input", function()
	describe("getNodes", function()
		local nodes

		before_each(function()
			nodes = input.getNodes()
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
				end
			end

			for _, apiName in ipairs({ "gamepadpressed", "gamepadreleased", "gamepadaxis" }) do
				assert.is_table(nodes.joysticks.apis[apiName])
				assert.equals("writable", nodes.joysticks.apis[apiName].atag)
			end
		end)
	end)

	describe("getCallbacks", function()
		it("should map LOVE input callbacks to node APIs", function()
			local nodes = input.getNodes()
			local callbacks = input.getCallbacks(nodes)

			assert.same({
				joystickadded = nodes.joysticks.apis.added,
				joystickremoved = nodes.joysticks.apis.removed,
				joystickpressed = nodes.joysticks.apis.pressed,
				joystickreleased = nodes.joysticks.apis.released,
				joystickaxis = nodes.joysticks.apis.axis,
				joystickhat = nodes.joysticks.apis.hat,
				gamepadpressed = nodes.joysticks.apis.pressed,
				gamepadreleased = nodes.joysticks.apis.released,
				gamepadaxis = nodes.joysticks.apis.axis,
				mousemoved = nodes.mouse.apis.moved,
				mousepressed = nodes.mouse.apis.pressed,
				mousereleased = nodes.mouse.apis.released,
				mousefocus = nodes.mouse.apis.focus,
				keypressed = nodes.keyboard.apis.pressed,
				keyreleased = nodes.keyboard.apis.released,
				wheelmoved = nodes.wheel.apis.moved,
			}, callbacks)
		end)
	end)
end)
