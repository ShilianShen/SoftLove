package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local Widget = require("softlove.ui.Widget")
local WidgetType = require("softlove.ui.WidgetType")

local function widget(patch)
	return WidgetType.newWidgetType(nil, patch)()
end

describe("Widget traversal", function()
	for _, method in ipairs({ "layout", "draw", "update", "focus" }) do
		it("should process itself and recurse through child " .. method .. " methods", function()
			local calls = {}
			local context = { x = 0, y = 0, w = 100, h = 100 }
			local hook = "_" .. method
			local function process(self, arg, y)
				calls[#calls + 1] = self.state.name
				if method == "layout" then
					assert.equals(self.state.name == "root" and context or self.state.parent, arg)
				elseif method == "focus" then
					assert.equals(5, arg)
					assert.equals(6, y)
					return self, { [self.state.name] = true }
				else
					assert.equals(context, arg)
				end
			end
			local root = widget({
				state = { name = "root" },
				[hook] = process,
				children = {
					child = widget({
						state = { name = "child" },
						[hook] = process,
						[method] = function(self, ...)
							calls[#calls + 1] = "child entry"
							return Widget[method](self, ...)
						end,
						children = { leaf = widget({ state = { name = "leaf" }, [hook] = process }) },
					}),
				},
			})
			root.children.child.state.parent = root
			root.children.child.children.leaf.state.parent = root.children.child
			if method == "focus" then
				local hit, hooks = root:focus(5, 6)
				assert.equals(root.children.child.children.leaf, hit)
				assert.same({ root = true, child = true, leaf = true }, hooks)
			else
				root[method](root, context)
			end
			assert.same({ "root", "child entry", "child", "leaf" }, calls)
		end)
	end

	it("should update a subtree root exactly once without updating its parent", function()
		local function count(self)
			self.state.count = (self.state.count or 0) + 1
		end
		local root = widget({
			_update = count,
			children = { child = widget({ _update = count, children = { leaf = widget({ _update = count }) } }) },
		})
		root:update({})
		root.children.child:update({})
		assert.equals(1, root.state.count)
		assert.equals(2, root.children.child.state.count)
		assert.equals(2, root.children.child.children.leaf.state.count)
	end)

	it("should preserve updates for inactive widgets so they can reactivate", function()
		local root = widget({
			active = false,
			_update = function(self)
				self.active = true
			end,
			children = { child = widget({
				active = false,
				_update = function(self)
					self.active = true
				end,
			}) },
		})
		root:update({})
		assert.is_true(root.active)
		assert.is_true(root.children.child.active)
	end)

	it("should skip inactive subtrees during layout, drawing and focus", function()
		local function unexpected()
			error("inactive subtree was processed")
		end
		local root = widget({
			children = {
				child = widget({
					active = false,
					_layout = unexpected,
					_draw = unexpected,
					_focus = unexpected,
					children = { leaf = widget({ _layout = unexpected, _draw = unexpected, _focus = unexpected }) },
				}),
			},
		})
		root:layout({ x = 0, y = 0, w = 100, h = 100 })
		root:draw({})
		assert.equals(root, root:focus(5, 5))
	end)

	it("should draw and hit children outside an invisible parent", function()
		local drawn = {}
		local root = widget({
			x = 0,
			y = 0,
			w = 10,
			h = 10,
			visible = false,
			_draw = function()
				drawn[#drawn + 1] = "root"
			end,
			children = {
				child = widget({
					x = 20,
					y = 20,
					w = 10,
					h = 10,
					_draw = function()
						drawn[#drawn + 1] = "child"
					end,
				}),
			},
		})
		root:draw({})
		assert.same({ "child" }, drawn)
		assert.equals(root.children.child, root:focus(25, 25))
		assert.is_nil(root:focus(5, 5))
	end)

	it("should preserve z order and merge hooks from all hits without changing their source", function()
		local ownHooks = { root = true, shared = "root" }
		local root = widget({
			w = 100,
			h = 100,
			hooked = function()
				return ownHooks
			end,
			children = {
				high = widget({
					z = 2,
					w = 100,
					h = 100,
					hooked = function()
						return { high = true, shared = "high" }
					end,
				}),
				low = widget({
					z = 1,
					w = 100,
					h = 100,
					hooked = function()
						return { low = true, shared = "low" }
					end,
					children = {
						leaf = widget({
							w = 100,
							h = 100,
							hooked = function()
								return { leaf = true, shared = "leaf" }
							end,
						}),
					},
				}),
			},
		})
		local hit, hooks = root:focus(5, 5)
		assert.equals(root.children.high, hit)
		assert.same({ root = true, low = true, leaf = true, high = true, shared = "high" }, hooks)
		assert.same({ root = true, shared = "root" }, ownHooks)
	end)

	it("should let a child override focus results and hooks", function()
		local root = widget({
			children = {
				child = widget({
					focus = function(self, x, y)
						assert.equals(25, x)
						assert.equals(30, y)
						return self, { custom = true }
					end,
				}),
			},
		})
		local hit, hooks = root:focus(25, 30)
		assert.equals(root.children.child, hit)
		assert.same({ custom = true }, hooks)
	end)

	it("should respect inside and return no hooks when nothing is hit", function()
		local root = widget({
			w = 100,
			h = 100,
			inside = function()
				return false
			end,
		})
		local hit, hooks = root:focus(5, 5)
		assert.is_nil(hit)
		assert.is_nil(hooks)
	end)
end)
