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
		assert.same({}, widget.userData)
		assert.same({}, widget.loveData)
		assert.is_nil(widget.state)
		assert.same({}, widget.children)
		assert.equals(Widget.layout, widget.layout)
		assert.equals(Widget.draw, widget.draw)
		assert.equals(Widget.update, widget.update)
		assert.equals(Widget.hook, widget.hook)
		assert.is_nil(widget.focus)
		assert.is_nil(widget._focus)
		assert.is_nil(widget.newWidget)
		assert.is_nil(widget.newWidgetType)
		assert.is_nil(widget.MT)
	end)

	it("should isolate user inputs and derived rendering data across instances", function()
		local inputs = { value = 3 }
		local panel = WidgetType.newWidgetType(nil, {
			userData = inputs,
			_update = function(self)
				self.loveData.text = tostring(self.userData.value * 2)
			end,
		})
		local first, second = panel(), panel()
		first:update({})
		assert.same({ value = 3 }, inputs)
		assert.same({ value = 3 }, first.userData)
		assert.same({ text = "6" }, first.loveData)
		assert.same({}, second.loveData)
		first.userData.value = 4
		first:update({})
		assert.equals("8", first.loveData.text)
		assert.equals(3, second.userData.value)
		assert.is_nil(panel.loveData)
	end)

	it("should isolate parent types, derived types and instances", function()
		local config = { userData = { count = 1 }, children = { label = { userData = { text = "a" } } } }
		local parent = WidgetType.newWidgetType(nil, config)
		local child = parent:newWidgetType()
		local first = child:newWidget()
		local second = child:newWidget()

		config.userData.count = 2
		parent.userData.count = 3
		first.userData.count = 4
		first.children.label.userData.text = "b"

		assert.equals(1, child.userData.count)
		assert.equals(1, second.userData.count)
		assert.equals("a", child.children.label.userData.text)
		assert.equals("a", second.children.label.userData.text)
	end)

	it("should replace nested fields as a whole", function()
		local parent = WidgetType.newWidgetType(nil, { userData = { a = 1, b = 2 } })
		local child = parent:newWidgetType({ userData = { a = 3 } })
		local widget = child:newWidget({ userData = { c = 4 } })

		assert.same({ a = 3 }, child.userData)
		assert.same({ c = 4 }, widget.userData)
	end)

	it("should support callable types from the WidgetType module", function()
		local panel = WidgetType.newWidgetType(nil, { w = 200 })

		assert.same(panel:newWidget({ x = 20 }), panel({ x = 20 }))
		assert.same(panel:newWidget(), panel())
	end)

	it("should isolate sibling children created from a shared widget", function()
		local label = WidgetType.newWidgetType(nil, { userData = { text = "Original" } })()
		local panel = WidgetType.newWidgetType(nil, { children = { first = label, second = label } })()
		panel.children.first.userData.text = "Changed"
		assert.equals("Original", panel.children.second.userData.text)
		assert.equals("Original", label.userData.text)
	end)

	it("should reject cyclic patches at both type and instance construction", function()
		local patch = { userData = {} }
		patch.userData.self = patch.userData
		assert.has_error(function()
			WidgetType.newWidgetType(nil, patch)
		end, "deepcopyDAGToTree: cycle detected at root[userData][self]")
		local widgetType = WidgetType.newWidgetType()
		assert.has_error(function()
			widgetType(patch)
		end, "deepcopyDAGToTree: cycle detected at root[userData][self]")
	end)
end)
