package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")

describe("softlove", function()
	local softlove, previousLove, previousModules
	local loadedModules = {
		"softlove",
		"softlove.util",
		"softlove.util.drawGraph",
		"softlove.util.drawGraph.Content",
		"softlove.util.drawGraph.getDAG",
		"softlove.util.drawGraph.style",
	}

	before_each(function()
		previousLove = _G.love
		_G.love = {
			graphics = {
				newFont = function() return {} end,
				newText = function() return {} end,
				line = function() end,
			},
		}
		previousModules = {}
		for _, name in ipairs(loadedModules) do
			previousModules[name] = package.loaded[name]
			package.loaded[name] = nil
		end
		softlove = require("softlove")
	end)

	after_each(function()
		_G.love = previousLove
		for _, name in ipairs(loadedModules) do
			package.loaded[name] = previousModules[name]
		end
	end)

	it("should expose the modules and relocated utility tools", function()
		for _, name in ipairs({ "ui", "input", "system", "assets", "util" }) do
			assert.equals(require("softlove." .. name), softlove[name])
		end
		assert.equals(require("softlove.util.Scope"), softlove.util.Scope)
		assert.equals(require("softlove.util.TimeProfiler"), softlove.util.TimeProfiler)
		assert.equals(require("softlove.util.drawGraph"), softlove.util.drawGraph)
	end)

	describe("setCallbacks", function()
		local bindings = {
			window = { focus = "focus", resize = "resize", visible = "visible" },
			joysticks = {
				joystickadded = "added",
				joystickremoved = "removed",
				joystickpressed = "pressed",
				joystickreleased = "released",
				joystickaxis = "axis",
				joystickhat = "hat",
				gamepadpressed = "pressed",
				gamepadreleased = "released",
				gamepadaxis = "axis",
			},
			mouse = { mousemoved = "moved", mousepressed = "pressed", mousereleased = "released", mousefocus = "focus" },
			keyboard = { keypressed = "pressed", keyreleased = "released" },
			wheel = { wheelmoved = "moved" },
		}

		local function makeNode(callbacks)
			local node = { apis = {} }
			for _, api in pairs(callbacks) do
				node.apis[api] = function(...) return ... end
			end
			return node
		end

		local function checkBindings(nodes)
			for name, node in pairs(nodes) do
				for callback, api in pairs(bindings[name]) do
					assert.equals(node.apis[api], love[callback])
				end
			end
		end

		it("should bind all window and input callbacks to the supplied node APIs", function()
			local nodes = {}
			for name, callbacks in pairs(bindings) do
				nodes[name] = makeNode(callbacks)
			end
			softlove.setCallbacks(nodes)
			checkBindings(nodes)
			assert.same({ 10, 20, 30, 40 }, { love.mousemoved(10, 20, 30, 40) })
		end)

		for name, callbacks in pairs(bindings) do
			it("should bind " .. name .. " without requiring other nodes", function()
				local nodes = { [name] = makeNode(callbacks) }
				local existing = function() end
				love.update = existing
				softlove.setCallbacks(nodes)
				checkBindings(nodes)
				assert.equals(existing, love.update)
				for otherName, otherCallbacks in pairs(bindings) do
					if otherName ~= name then
						for callback in pairs(otherCallbacks) do
							assert.is_nil(love[callback])
						end
					end
				end
			end)
		end

		it("should leave existing callbacks intact when no nodes are supplied", function()
			local existing = function() end
			love.mousemoved = existing
			softlove.setCallbacks({})
			assert.equals(existing, love.mousemoved)
		end)
	end)
end)
