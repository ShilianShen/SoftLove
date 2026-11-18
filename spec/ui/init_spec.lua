package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local ui = require("softlove.ui")

local function initialize(widgets)
	local data = {}
	ui.Widgets(widgets).tasks.init.func(data)
	return data
end

local function rejects(widgets, message)
	local ok, err = pcall(initialize, widgets)
	assert.is_false(ok)
	assert.is_truthy(tostring(err):find(message, 1, true))
end

describe("ui declaration registry", function()
	it("should build an empty registry", function()
		assert.same({}, initialize({}).widgetTypes)
	end)

	it("should resolve inheritance chains independently of name order", function()
		local data = initialize({
			a = { type = "middle", bounds = { w = 20 }, visible = false },
			middle = { type = "z", bounds = { h = 30 } },
			z = { bounds = { w = 100, h = 200 }, visible = true },
		})
		local widget = data:newWidget("a")
		assert.equals(20, widget.bounds.w)
		assert.equals(30, widget.bounds.h)
		assert.is_false(widget.visible)
		assert.is_nil(widget.type)
		assert.is_nil(data.widgetTypes.a.type)
		assert.equals(100, data.widgetTypes.z.bounds.w)
	end)

	it("should build referenced child types and nested declarations before their owners", function()
		local data = initialize({
			aPage = {
				children = {
					group = {
						children = { { type = "zLabel", bounds = { w = 50 } } },
					},
				},
			},
			zLabel = { type = "base", userData = { text = "Hello" } },
			base = { bounds = { w = 100, h = 20 } },
		})
		local group = data:newWidget("aPage").children.group
		assert.is_true(group.active)
		local label = group.children[1]
		assert.equals(50, label.bounds.w)
		assert.equals(20, label.bounds.h)
		assert.equals("Hello", label.userData.text)
		assert.is_function(label.layout)
		assert.is_nil(label.type)
	end)

	it("should allow multiple declarations and children to share dependencies", function()
		local data = initialize({
			base = { bounds = { h = 10 } },
			left = { type = "base" },
			right = { type = "base" },
			page = { children = { { type = "left" }, { type = "right" }, { type = "left" } } },
		})
		local children = data:newWidget("page").children
		for _, child in ipairs(children) do
			assert.equals(10, child.bounds.h)
		end
	end)

	it("should preserve whole-field overrides and inherit omitted children", function()
		local data = initialize({
			base = { userData = { a = 1, b = 2 }, children = { label = { bounds = { w = 40 } } } },
			derived = { type = "base", userData = { a = 3 } },
			empty = { type = "base", children = {} },
		})
		local widget = data:newWidget("derived")
		assert.same({ a = 3 }, widget.userData)
		assert.equals(40, widget.children.label.bounds.w)
		assert.same({}, data:newWidget("empty").children)
	end)

	it("should isolate declarations, repeated children, instances and registry initializations", function()
		local child = { userData = { text = "Original" } }
		local widgets = { page = { children = { first = child, second = child } } }
		local node = ui.Widgets(widgets)
		local first, second = {}, {}
		node.tasks.init.func(first)
		node.tasks.init.func(second)
		first.widgetTypes.page.children.first.userData.text = "Type changed"
		local a, b = second:newWidget("page"), second:newWidget("page")
		a.children.first.userData.text = "Instance changed"
		assert.equals("Original", a.children.second.userData.text)
		assert.equals("Original", b.children.first.userData.text)
		assert.equals("Original", child.userData.text)
		assert.is_nil(child.active)
	end)

	it("should reject missing parents including those in nested children", function()
		rejects({ panel = { type = "missing" } }, "unknown widget type: missing at panel")
		rejects(
			{ page = { children = { label = { type = "missing" } } } },
			"unknown widget type: missing at page.children[label]"
		)
	end)

	it("should reject self inheritance and longer inheritance cycles", function()
		rejects({ a = { type = "a" } }, "a -> a")
		rejects({ a = { type = "b" }, b = { type = "c" }, c = { type = "a" } }, "a -> b -> c -> a")
	end)

	it("should reject cycles involving child type references", function()
		rejects({ a = { children = { { type = "a" } } } }, "dependency cycle")
		rejects({ a = { children = { { type = "b" } } }, b = { type = "a" } }, "a -> b -> a")
	end)

	it("should reject invalid declaration shapes and cyclic tables", function()
		rejects({ a = { type = 42 } }, "expected widget type name at a")
		rejects({ a = { children = false } }, "expected children table at a")
		rejects({ a = { children = { label = true } } }, "expected widget declaration at a.children[label]")
		rejects({ [1] = {} }, "expected string widget name")
		local cyclic = { children = {} }
		cyclic.children.self = cyclic
		rejects({ a = cyclic }, "cycle detected")
	end)

	it("should preserve an existing registry if rebuilding fails", function()
		local data = initialize({ base = { bounds = { w = 42 } } })
		local registry = data.widgetTypes
		local ok = pcall(ui.Widgets({ a = { type = "a" } }).tasks.init.func, data)
		assert.is_false(ok)
		assert.equals(registry, data.widgetTypes)
		assert.equals(42, data:newWidget("base").bounds.w)
	end)

	it("should continue supporting explicit registration and removal of built types", function()
		local node = ui.Widgets({ base = { bounds = { w = 42 } } })
		local data = {}
		node.tasks.init.func(data)
		node.apis.register.func(data, "alias", data.widgetTypes.base)
		assert.equals(42, data:newWidget("alias").bounds.w)
		node.apis.unregister.func(data, "alias")
		assert.has_error(function()
			data:newWidget("alias")
		end, "unknown widget type: alias")
	end)
end)
