package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local getPage = require("softlove.ui").getPage
local WidgetType = require("softlove.ui.WidgetType")

local function widget(patch)
	return WidgetType.newWidgetType(nil, patch)()
end

describe("getPage", function()
	it("should expose the page factory through ui", function()
		assert.is_function(getPage)
		assert.equals(require("softlove.ui.getPage"), getPage)
	end)

	it("should initialize a page and expose public descendants through get", function()
		local root = widget({ children = { label = widget({ public = true, z = 42 }) } })
		local node = getPage({
			init = { func = function(page) page.entry = root end },
		}, {})
		local page = {}
		node.tasks._init.func(page)
		assert.is_nil(page.entry)
		node.tasks.init.func(page)

		assert.equals(root, page.entry)
		assert.is_true(page.ui)
		assert.equals(42, page:get("label").z)
		assert.is_nil(page:get("missing"))
	end)

	it("should run content before update and layout using their declared dependencies", function()
		local calls = {}
		local root = widget({
			_update = function(self, params)
				assert.equals("Ready", self.userData.text)
				assert.equals("font source", params.fonts)
				assert.equals("locale source", params.locales)
				calls[#calls + 1] = "update"
			end,
			_layout = function(self, parent)
				assert.equals("update", calls[#calls])
				self.bounds.x, self.bounds.y, self.bounds.w, self.bounds.h = parent.x, parent.y, parent.w, parent.h
				calls[#calls + 1] = "layout"
			end,
		})
		local node = getPage({
			init = { func = function(page) page.entry = root end },
			content = {
				parents_c = { "init" },
				func = function(page)
					assert.equals(root, page.entry)
					page.entry.userData.text = "Ready"
					calls[#calls + 1] = "content"
				end,
			},
		}, {})
		assert.same({ "init", "_init" }, node.tasks.content.parents_c)
		local updateParents = {}
		for _, parent in ipairs(node.tasks._update.parents_c) do
			updateParents[parent] = true
		end
		assert.same({ _init = true, init = true, content = true }, updateParents)
		assert.same({ fonts = "fonts", locales = "locales" }, node.tasks._update.parents_d)
		assert.same({ "_update" }, node.tasks._layout.parents_c)
		assert.same({ window = "window" }, node.tasks._layout.parents_d)

		local page = {}
		node.tasks._init.func(page)
		node.tasks.init.func(page)
		node.tasks.content.func(page)
		node.tasks._update.func(page, { fonts = "font source", locales = "locale source" })
		node.tasks._layout.func(page, { window = { x = 10, y = 20, w = 300, h = 200 } })
		assert.same({ "content", "update", "layout" }, calls)
		assert.same({ 10, 20, 300, 200 }, { root.bounds.x, root.bounds.y, root.bounds.w, root.bounds.h })
	end)

	it("should preserve existing subtask dependencies without modifying caller declarations", function()
		local subtasks = {
			first = { func = function() end },
			second = { parents_c = { "first" } },
		}
		local node = getPage(subtasks, {})
		assert.same({ "first", "_init" }, node.tasks.second.parents_c)
		assert.same({ "first" }, subtasks.second.parents_c)
		assert.is_nil(subtasks.first.parents_c)
		node.tasks.second.parents_c[1] = "changed"
		assert.same({ "first" }, subtasks.second.parents_c)
	end)

	it("should forward the theme through draw without scheduling an update", function()
		local theme = { accent = "blue" }
		local draws = 0
		local node = getPage({
			init = {
				func = function(page)
					page.entry = widget({
						_draw = function(_, actual)
							assert.equals(theme, actual)
							draws = draws + 1
						end,
					})
				end,
			},
		}, {})
		local page = {}
		node.tasks._init.func(page)
		node.tasks.init.func(page)
		node.apis.draw.func(page, theme)
		assert.equals(1, draws)
		assert.is_false(node.apis.draw.dirty)
		assert.is_nil(node.apis.draw.ttag)
	end)

	it("should expose hook and return both the hit widget and information", function()
		local root = widget({
			bounds = {
				w = 100,
				h = 100,
			},
			hooked = function()
				return { id = "root" }
			end,
		})
		local node = getPage({
			init = { func = function(page) page.entry = root end },
		}, {})
		local page = {}
		node.tasks._init.func(page)
		node.tasks.init.func(page)
		local hit, info = node.apis.hook.func(page, 5, 6)
		assert.equals(root, hit)
		assert.same({ id = "root" }, info)
		local missed, noInfo = node.apis.hook.func(page, 105, 6)
		assert.is_nil(missed)
		assert.is_nil(noInfo)
		assert.is_false(node.apis.hook.dirty)
		assert.is_nil(node.apis.hook.ttag)
		assert.is_nil(node.apis.focus)
	end)

	it("should preserve custom APIs and their task targets without sharing declarations", function()
		local apis = {
			set = {
				func = function(page, text)
					page.entry.userData.text = text
				end,
				ttag = "content",
				atag = "writable",
				dirty = true,
			},
		}
		local node = getPage({
			content = { func = function(page) page.entry = widget() end },
		}, apis)
		local page = {}
		node.tasks._init.func(page)
		node.tasks.content.func(page)
		node.apis.set.func(page, "Updated")
		assert.equals("Updated", page.entry.userData.text)
		assert.equals("content", node.apis.set.ttag)
		assert.is_true(node.apis.set.dirty)
		node.apis.set.ttag = "changed"
		assert.equals("content", apis.set.ttag)
		assert.is_nil(apis.draw)
		assert.is_nil(apis.hook)
	end)

	it("should keep declarations independent when reused for multiple pages", function()
		local tasks, apis = { content = {} }, { set = { dirty = true } }
		local first = getPage(tasks, apis)
		local second = getPage(tasks, apis)
		first.tasks.content.parents_c[1] = "changed"
		first.apis.set.dirty = false
		assert.same({ "_init" }, second.tasks.content.parents_c)
		assert.is_true(second.apis.set.dirty)
		assert.is_nil(tasks.content.parents_c)
	end)
end)
