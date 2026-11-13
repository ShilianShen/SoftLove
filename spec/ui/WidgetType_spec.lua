package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local WidgetType = require("softlove.ui.WidgetType")
local Widget = require("softlove.ui.Widget")

describe("WidgetType", function()
	it("should create and derive types with patch precedence", function()
		local parent = WidgetType.newWidgetType(nil, { w = 200, h = 100, visible = true })
		local child = WidgetType.newWidgetType(parent, { w = 100, visible = false })
		local grandchild = child:newWidgetType({ h = 50 })

		assert.equals(200, parent.w)
		assert.equals(100, child.w)
		assert.equals(100, child.h)
		assert.is_false(child.visible)
		assert.equals(100, grandchild.w)
		assert.equals(50, grandchild.h)
		assert.is_nil(rawget(child, "newWidget"))
		assert.is_nil(rawget(child, "newWidgetType"))
	end)

	it("should fill instance defaults after applying type and instance patches", function()
		local panel = WidgetType.newWidgetType(nil, { w = 200, visible = true })
		local widget = panel:newWidget({ w = 100, visible = false })

		assert.equals(100, widget.w)
		assert.is_false(widget.visible)
		assert.is_true(widget.active)
		assert.same({}, widget.state)
		assert.same({}, widget.children)
		assert.equals(Widget.layout, widget.layout)
		assert.equals(Widget.draw, widget.draw)
		assert.equals(Widget.update, widget.update)
		assert.is_nil(widget.newWidget)
		assert.is_nil(widget.newWidgetType)
		assert.is_nil(widget.MT)
	end)

	it("should isolate parent types, derived types and instances", function()
		local config = { state = { count = 1 }, children = { label = { state = { text = "a" } } } }
		local parent = WidgetType.newWidgetType(nil, config)
		local child = parent:newWidgetType()
		local first = child:newWidget()
		local second = child:newWidget()

		config.state.count = 2
		parent.state.count = 3
		first.state.count = 4
		first.children.label.state.text = "b"

		assert.equals(1, child.state.count)
		assert.equals(1, second.state.count)
		assert.equals("a", child.children.label.state.text)
		assert.equals("a", second.children.label.state.text)
	end)

	it("should replace nested fields as a whole", function()
		local parent = WidgetType.newWidgetType(nil, { state = { a = 1, b = 2 } })
		local child = parent:newWidgetType({ state = { a = 3 } })
		local widget = child:newWidget({ state = { c = 4 } })

		assert.same({ a = 3 }, child.state)
		assert.same({ c = 4 }, widget.state)
	end)

	it("should expose the factory through ui and support callable types", function()
		assert.equals(WidgetType, require("softlove.ui").WidgetType)
		local panel = WidgetType.newWidgetType(nil, { w = 200 })

		assert.same(panel:newWidget({ x = 20 }), panel({ x = 20 }))
		assert.same(panel:newWidget(), panel())
	end)
end)
