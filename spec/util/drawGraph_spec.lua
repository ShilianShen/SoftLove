package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")

describe("drawGraph selection", function()
	local drawGraph, previousLove, previousModules, mouseX, mouseY, rendered
	local modules = {
		"softlove.util.drawGraph",
		"softlove.util.drawGraph.Content",
		"softlove.util.drawGraph.getDAG",
		"softlove.util.drawGraph.style",
	}

	before_each(function()
		previousLove = _G.love
		previousModules = {}
		for _, name in ipairs(modules) do
			previousModules[name] = package.loaded[name]
			package.loaded[name] = nil
		end
		local font = {
			getWidth = function(_, text)
				return #text * 8
			end,
			getHeight = function()
				return 12
			end,
		}
		_G.love = {
			graphics = {
				newFont = function()
					return font
				end,
				newText = function()
					return {
						setf = function(_, text)
							rendered[#rendered + 1] = text
						end,
						setFont = function() end,
						getHeight = function()
							return 12
						end,
					}
				end,
				getDimensions = function()
					return 1000, 600
				end,
				push = function() end,
				pop = function() end,
				setColor = function() end,
				draw = function() end,
				line = function() end,
			},
			mouse = {
				getPosition = function()
					return mouseX, mouseY
				end,
			},
		}
		require("softlove.util.drawGraph.Content").draw = function() end
		drawGraph = require("softlove.util.drawGraph")
	end)

	after_each(function()
		_G.love = previousLove
		for _, name in ipairs(modules) do
			package.loaded[name] = previousModules[name]
		end
	end)

	local function graph(ntag, ttag, marker)
		return {
			nodes = {
				[ntag] = {
					data = { marker = marker .. "-data" },
					tasks = { [ttag] = { marker = marker .. "-task" } },
					parents_c = { [ttag] = {} },
					children_c = { [ttag] = {} },
					order_c = { ttag },
				},
			},
			parents_n = { [ntag] = {} },
			children_n = { [ntag] = {} },
			order_n = { ntag },
			parents_d = { [ntag] = { [ttag] = {} } },
		}
	end

	local function render(value, x, y)
		mouseX, mouseY = x or 900, y or 0
		rendered = {}
		drawGraph(value)
		return rendered[1]
	end

	it("should isolate and restore selections when switching between graphs", function()
		local first = graph("first", "work", "A")
		local second = graph("second", "update", "B")
		assert.matches("A-data", render(first, 300, 180), 1, true)
		assert.matches("A-task", render(first, 300, 480), 1, true)
		assert.is_nil(render(second))
		assert.matches("B-data", render(second, 300, 180), 1, true)
		assert.matches("B-task", render(second, 300, 480), 1, true)
		assert.matches("A-task", render(first), 1, true)
		assert.matches("B-task", render(second), 1, true)
	end)

	it("should isolate graphs with the same node names and different tasks", function()
		local first = graph("shared", "work", "A")
		local second = graph("shared", "update", "B")
		render(first, 300, 180)
		render(first, 300, 480)
		assert.is_nil(render(second))
		assert.matches("B-data", render(second, 300, 180), 1, true)
		assert.matches("A-task", render(first), 1, true)
	end)

	it("should allow switching to an empty graph and back", function()
		local first = graph("first", "work", "A")
		render(first, 300, 180)
		render(first, 300, 480)
		assert.is_nil(render({ nodes = {}, parents_n = {}, children_n = {}, order_n = {}, parents_d = {} }))
		assert.matches("A-task", render(first), 1, true)
	end)

	it("should clear selections whose tasks or nodes have been removed", function()
		local value = graph("first", "work", "A")
		render(value, 300, 180)
		render(value, 300, 480)
		local node = value.nodes.first
		node.tasks, node.parents_c, node.children_c, node.order_c = {}, {}, {}, {}
		value.parents_d.first = {}
		assert.matches("A-data", render(value), 1, true)
		value.nodes, value.parents_n, value.children_n, value.order_n, value.parents_d = {}, {}, {}, {}, {}
		assert.is_nil(render(value))
	end)
end)
