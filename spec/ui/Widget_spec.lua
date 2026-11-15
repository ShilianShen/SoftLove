package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local Widget = require("softlove.ui.Widget")
local WidgetType = require("softlove.ui.WidgetType")

local function widget(patch)
	return WidgetType.newWidgetType(nil, patch)()
end

describe("Widget sorting", function()
	it("should recursively sort all children by depth and retain the actual child instances", function()
		local root = widget({
			active = false,
			children = {
				high = widget({ depth = 10, visible = false }),
				low = widget({
					depth = -10,
					active = false,
					children = { high = widget({ depth = 2 }), low = widget({ depth = 1 }) },
				}),
			},
		})
		root:sort()
		assert.equals(2, #root.order)
		assert.equals(root.children.high, root.order[1])
		assert.equals(root.children.low, root.order[2])
		local low = root.children.low
		assert.equals(low.children.high, low.order[1])
		assert.equals(low.children.low, low.order[2])
		assert.same({}, root.children.high.order)
		assert.same({}, low.children.low.order)
	end)

	it("should keep every child with equal depth without requiring a tie order", function()
		local root = widget({ children = { first = widget({ depth = 1 }), second = widget({ depth = 1 }) } })
		root:sort()
		assert.equals(2, #root.order)
		local found = {}
		for _, child in ipairs(root.order) do
			found[child] = true
		end
		assert.is_true(found[root.children.first])
		assert.is_true(found[root.children.second])
		root.children = {}
		root:sort()
		assert.same({}, root.order)
	end)

	for _, method in ipairs({ "draw", "update", "hook" }) do
		it("should use cached order until sort is called again during " .. method, function()
			local calls = {}
			local function child(name, depth)
				local function process(self)
					calls[#calls + 1] = name
					return self, {}
				end
				return widget({ depth = depth, _draw = process, _update = process, _hook = process })
			end
			local root = widget({ children = { low = child("low", -1), high = child("high", 1) } })
			root[method](root, 5, 5)
			assert.same({}, calls)
			root:sort()
			local cached = root.order
			local low = root.children.low
			root.children.low.depth = 10
			root.children.high.depth = -10
			root.children.low = nil
			root.children.middle = child("middle", 0)
			local hit = root[method](root, 5, 5)
			assert.same({ "high", "low" }, calls)
			assert.equals(cached, root.order)
			if method == "hook" then
				assert.equals(low, hit)
			end
			calls = {}
			root:sort()
			hit = root[method](root, 5, 5)
			assert.same({ "middle", "high" }, calls)
			assert.equals(root.children.middle, root.order[1])
			assert.equals(root.children.high, root.order[2])
			if method == "hook" then
				assert.equals(root.children.high, hit)
			end
		end)
	end
end)

describe("Widget traversal", function()
	for _, method in ipairs({ "layout", "draw", "update", "hook" }) do
		it("should process itself and recurse through child " .. method .. " methods", function()
			local calls = {}
			local context = { x = 0, y = 0, w = 100, h = 100 }
			local hook = "_" .. method
			local function process(self, arg, y, themes)
				if method == "draw" then
					calls[#calls + 1] = self.name
					assert.equals(context, themes)
					return
				end
				if method == "update" then
					calls[#calls + 1] = self.name
					assert.equals(context, y)
					return
				end
				calls[#calls + 1] = self.userData.name
				if method == "layout" then
					assert.equals(self.userData.name == "root" and context or self.userData.parent.bounds, arg)
				elseif method == "hook" then
					assert.equals(5, arg)
					assert.equals(6, y)
					return self, { [self.userData.name] = true }
				end
			end
			local root = widget({
				userData = { name = "root" },
				[hook] = process,
				children = {
					child = widget({
						userData = { name = "child" },
						[hook] = process,
						[method] = function(self, ...)
							calls[#calls + 1] = "child entry"
							return Widget[method](self, ...)
						end,
						children = { leaf = widget({ userData = { name = "leaf" }, [hook] = process }) },
					}),
				},
			})
			root.children.child.userData.parent = root
			root.children.child.children.leaf.userData.parent = root.children.child
			root:sort()
			if method == "hook" then
				local hit, hooks = root:hook(5, 6)
				assert.equals(root.children.child.children.leaf, hit)
				assert.same({ root = true, child = true, leaf = true }, hooks)
			else
				root[method](root, context)
			end
			assert.same({ "root", "child entry", "child", "leaf" }, calls)
		end)
	end

	it("should update a subtree root exactly once without updating its parent", function()
		local function count(userData, loveData, params)
			loveData.count = (loveData.count or 0) + 1
		end
		local root = widget({
			_update = count,
			children = { child = widget({ _update = count, children = { leaf = widget({ _update = count }) } }) },
		})
		root:sort()
		root:update({})
		root.children.child:update({})
		assert.equals(1, root.loveData.count)
		assert.equals(2, root.children.child.loveData.count)
		assert.equals(2, root.children.child.children.leaf.loveData.count)
	end)

	it("should skip updates for inactive subtrees until externally reactivated", function()
		local calls = {}
		local root = widget({
			active = false,
			_update = function()
				calls[#calls + 1] = "root"
			end,
			children = {
				child = widget({
					active = true,
					_update = function()
						calls[#calls + 1] = "child"
					end,
					children = {
						leaf = widget({
							_update = function()
								calls[#calls + 1] = "leaf"
							end,
						}),
					},
				}),
			},
		})
		root:sort()
		root:update({})
		assert.is_false(root.active)
		assert.same({}, calls)
		assert.is_true(root.children.child.active)
		root.children.child.active = false
		root.active = true
		root:update({})
		assert.is_false(root.children.child.active)
		assert.same({ "root" }, calls)
		root.children.child.active = true
		root:update({})
		assert.is_true(root.children.child.active)
		assert.same({ "root", "root", "child", "leaf" }, calls)
	end)

	it("should skip inactive subtrees during layout, drawing and hook", function()
		local function unexpected()
			error("inactive subtree was processed")
		end
		local root = widget({
			children = {
				child = widget({
					active = false,
					_layout = unexpected,
					_draw = unexpected,
					_hook = unexpected,
					children = { leaf = widget({ _layout = unexpected, _draw = unexpected, _hook = unexpected }) },
				}),
			},
		})
		root:sort()
		root:layout({ x = 0, y = 0, w = 100, h = 100 })
		root:draw({})
		assert.equals(root, root:hook(5, 5))
	end)

	it("should draw and hit children outside an invisible parent", function()
		local drawn = {}
		local root = widget({
			bounds = {
				x = 0,
				y = 0,
				w = 10,
				h = 10,
			},
			visible = false,
			_draw = function()
				drawn[#drawn + 1] = "root"
			end,
			children = {
				child = widget({
					bounds = {
						x = 20,
						y = 20,
						w = 10,
						h = 10,
					},
					_draw = function()
						drawn[#drawn + 1] = "child"
					end,
				}),
			},
		})
		root:sort()
		root:draw({})
		assert.same({ "child" }, drawn)
		assert.equals(root.children.child, root:hook(25, 25))
		assert.is_nil(root:hook(5, 5))
	end)

	it("should preserve depth order and merge hooks from all hits without changing their source", function()
		local ownHooks = { root = true, shared = "root" }
		local root = widget({
			bounds = {
				w = 100,
				h = 100,
			},
			hooked = function()
				return ownHooks
			end,
			children = {
				high = widget({
					depth = 2,
					bounds = {
						w = 100,
						h = 100,
					},
					hooked = function()
						return { high = true, shared = "high" }
					end,
				}),
				low = widget({
					depth = 1,
					bounds = {
						w = 100,
						h = 100,
					},
					hooked = function()
						return { low = true, shared = "low" }
					end,
					children = {
						leaf = widget({
							bounds = {
								w = 100,
								h = 100,
							},
							hooked = function()
								return { leaf = true, shared = "leaf" }
							end,
						}),
					},
				}),
			},
		})
		root:sort()
		local hit, hooks = root:hook(5, 5)
		assert.equals(root.children.low.children.leaf, hit)
		assert.same({ root = true, low = true, leaf = true, high = true, shared = "leaf" }, hooks)
		assert.same({ root = true, shared = "root" }, ownHooks)
	end)

	it("should let a child override hook results and hooks", function()
		local root = widget({
			children = {
				child = widget({
					hook = function(self, x, y)
						assert.equals(25, x)
						assert.equals(30, y)
						return self, { custom = true }
					end,
				}),
			},
		})
		root:sort()
		local hit, hooks = root:hook(25, 30)
		assert.equals(root.children.child, hit)
		assert.same({ custom = true }, hooks)
	end)

	it("should respect inside and return no hooks when nothing is hit", function()
		local root = widget({
			bounds = {
				w = 100,
				h = 100,
			},
			inside = function()
				return false
			end,
		})
		local hit, hooks = root:hook(5, 5)
		assert.is_nil(hit)
		assert.is_nil(hooks)
	end)
end)

describe("Widget defaults", function()
	it("should pass each widget's data, child userData map and the shared params to update", function()
		local calls = {}
		local function process(...)
			assert.equals(4, select("#", ...))
			local userData, loveData, params, children = ...
			calls[#calls + 1] = { ... }
			loveData.text = userData.text .. params.locales.suffix
			if children.child then
				children.child.text = userData.text .. "/child"
			end
		end
		local root = widget({
			userData = { text = "root" },
			_update = process,
			children = {
				child = widget({ userData = { text = "child" }, _update = process }),
				[2] = widget({ depth = 1, userData = { text = "numeric" }, _update = process }),
			},
		})
		local params = { locales = { suffix = "!" } }
		root:sort()
		root:update(params)
		assert.equals(3, #calls)
		for i, item in ipairs({ root, root.children[2], root.children.child }) do
			assert.equals(item.userData, calls[i][1])
			assert.equals(item.loveData, calls[i][2])
			assert.equals(params, calls[i][3])
			assert.is_false(item.children == calls[i][4])
			local expected = {}
			for key, child in pairs(item.children) do
				assert.equals(child.userData, calls[i][4][key])
				expected[key] = child.userData
			end
			assert.same(expected, calls[i][4])
			assert.equals(item.userData.text .. "!", item.loveData.text)
		end
		assert.equals("root/child!", root.children.child.loveData.text)
	end)

	it("should share child data while keeping edits to the temporary map separate from actual children", function()
		local maps = {}
		local root = widget({
			_update = function(userData, loveData, params, children)
				assert.is_nil(children.extra)
				maps[#maps + 1] = children
				children.child.count = (children.child.count or 0) + 1
				children.child = { count = -1 }
				children.extra = {}
			end,
			children = {
				child = widget({
					_update = function(userData, loveData)
						loveData.count = userData.count
					end,
				}),
			},
		})
		root:sort()
		root:update({})
		root:update({})
		assert.is_false(maps[1] == maps[2])
		assert.is_nil(root.children.extra)
		assert.equals(2, root.children.child.userData.count)
		assert.equals(2, root.children.child.loveData.count)
	end)

	it("should pass exactly each widget's userData, loveData, bounds and the shared themes to draw", function()
		local calls = {}
		local function capture(...)
			assert.equals(4, select("#", ...))
			calls[#calls + 1] = { ... }
		end
		local root = widget({
			userData = { text = "root" },
			loveData = { text = "ROOT" },
			_draw = capture,
			children = {
				child = widget({ userData = { text = "child" }, loveData = { text = "CHILD" }, _draw = capture }),
			},
		})
		local themes = { text = { 1, 1, 1, 1 } }
		root:sort()
		root:draw(themes)
		assert.equals(2, #calls)
		for i, item in ipairs({ root, root.children.child }) do
			assert.equals(item.userData, calls[i][1])
			assert.equals(item.loveData, calls[i][2])
			assert.equals(item.bounds, calls[i][3])
			assert.equals(themes, calls[i][4])
		end
	end)

	it("should inherit parent bounds through multiple levels", function()
		local root = widget({ children = { panel = widget({ children = { label = widget() } }) } })
		root:layout({ x = 12, y = 34, w = 300, h = 200 })
		for _, item in ipairs({ root, root.children.panel, root.children.panel.children.label }) do
			assert.same({ 12, 34, 300, 200 }, { item.bounds.x, item.bounds.y, item.bounds.w, item.bounds.h })
		end
	end)

	for _, method in ipairs({ "draw", "update" }) do
		it("should process deeper siblings first in decreasing depth order during " .. method, function()
			local calls = {}
			local function child(name, depth)
				return widget({
					depth = depth,
					["_" .. method] = function()
						calls[#calls + 1] = name
					end,
				})
			end
			local root = widget({
				children = {
					a = child("high", 10),
					b = child("low", -10),
					c = child("middle", 0),
				},
			})
			root:sort()
			root[method](root, {})
			assert.same({ "high", "middle", "low" }, calls)
		end)
	end

	-- Current bounds use strict inequalities: edges themselves are not hits.
	for _, point in ipairs({
		{ name = "left edge", x = 10, y = 30 },
		{ name = "right edge", x = 110, y = 30 },
		{ name = "top edge", x = 30, y = 20 },
		{ name = "bottom edge", x = 30, y = 70 },
		{ name = "outside", x = 111, y = 71 },
	}) do
		it("should not hook or request information at the " .. point.name, function()
			local root = widget({
				bounds = {
					x = 10,
					y = 20,
					w = 100,
					h = 50,
				},
				hooked = function()
					error("information requested for a miss")
				end,
			})
			local hit, info = root:hook(point.x, point.y)
			assert.is_nil(hit)
			assert.is_nil(info)
		end)
	end

	it("should return information without executing functions contained in it", function()
		local action = function()
			error("UI executed an action")
		end
		local root = widget({
			bounds = {
				w = 100,
				h = 100,
			},
			hooked = function()
				return { id = 7, action = action }
			end,
		})
		local hit, info = root:hook(50, 50)
		assert.equals(root, hit)
		assert.equals(7, info.id)
		assert.equals(action, info.action)
	end)

	it("should return an empty information table for a default hit", function()
		local root = widget({ bounds = { w = 100, h = 100 } })
		local hit, info = root:hook(50, 50)
		assert.equals(root, hit)
		assert.same({}, info)
	end)

	it("should not reuse merged information between hook calls", function()
		local root = widget({
			bounds = {
				w = 100,
				h = 100,
			},
			children = {
				child = widget({
					bounds = {
						w = 20,
						h = 20,
					},
					hooked = function()
						return { child = true }
					end,
				}),
			},
		})
		root:sort()
		local _, first = root:hook(10, 10)
		first.extra = true
		local hit, second = root:hook(50, 50)
		assert.equals(root, hit)
		assert.same({}, second)
	end)
end)

describe("Widget public access", function()
	it("should return nil for private widgets and missing paths", function()
		local root = widget({ children = { private = widget() } })
		assert.is_nil(Widget.get(root))
		assert.is_nil(Widget.get(root, "private"))
		assert.is_nil(Widget.get(root, "missing", "leaf"))
	end)

	it("should allow a public descendant beneath a private ancestor", function()
		local root = widget({
			children = { panel = widget({ children = {
				label = widget({ public = true, depth = 42 }),
			} }) },
		})
		assert.is_nil(Widget.get(root, "panel"))
		assert.equals(42, Widget.get(root, "panel", "label").depth)
	end)

	it("should expose live scalar values while hiding tables and functions", function()
		local root = widget({ public = true, depth = 42, visible = false, title = "Label" })
		local view = Widget.get(root)
		assert.equals(42, view.depth)
		assert.is_false(view.visible)
		assert.equals("Label", view.title)
		assert.is_nil(view.bounds)
		assert.is_nil(view.userData)
		assert.is_nil(view.loveData)
		assert.is_nil(view.children)
		assert.is_nil(view.draw)
		assert.is_nil(view.hook)
		root.depth = 84
		assert.equals(84, view.depth)
	end)

	it("should reject replacing and adding fields through the public view", function()
		local root = widget({ public = true, depth = 42 })
		local view = Widget.get(root)
		assert.has_error(function()
			view.depth = 100
		end, "attempt to modify a constant table (key = depth)")
		assert.has_error(function()
			view.extra = true
		end, "attempt to modify a constant table (key = extra)")
		assert.equals(42, root.depth)
		assert.is_nil(root.extra)
	end)
end)
