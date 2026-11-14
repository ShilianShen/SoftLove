local util = require("softlove.ui.util")
local Widget = require("softlove.ui.Widget")

---@class softlove.ui.Page
---@field entry softlove.ui.Widget
---@field get fun(self: softlove.ui.Page, ...: any): table?
local Page = {}

---@param page softlove.ui.Page
local function layoutPage(page, params)
	assert(params ~= nil)
	page.entry:layout(params.window)
end

---@param page softlove.ui.Page
---@param theme softlove.ui.Theme
local function drawPage(page, theme)
	page.entry:draw(theme)
end

---@param page softlove.ui.Page
local function updatePage(page, params)
	page.entry:update(params)
end

---@param page softlove.ui.Page
local function hookPage(page, x, y)
	return page.entry:hook(x, y)
end

---@param self softlove.ui.Page
local function get(self, ...)
	return Widget.get(self.entry, ...)
end

---User subtasks must assign self.entry before _update runs.
---@param subtasks table<string, softdep.declaration.Task>
---@param apis table<string, softdep.declaration.Api>
---@return softdep.declaration.Node
function Page.Node(subtasks, apis)
	apis = util.deepcopyDAGToTree(apis)
	---@type table<string, softdep.declaration.Task>
	local tasks = util.deepcopyDAGToTree(subtasks)
	local parents_c = { "_init" }
	for k, task in pairs(tasks) do
		parents_c[#parents_c + 1] = k
		task.parents_c = task.parents_c or {}
		table.insert(task.parents_c, "_init")
	end
	tasks._init = {
		func = function(self)
			self.get = get
			self.ui = true
		end,
		atag = "writable",
		back = false,
	}
	tasks._update = {
		func = updatePage,
		parents_c = parents_c,
		parents_d = { fonts = "fonts", locales = "locales" },
		atag = "writable",
		back = false,
	}
	tasks._layout = {
		func = layoutPage,
		parents_d = { window = "window" },
		parents_c = { "_update" },
		atag = "writable",
		back = false,
	}
	apis.draw = {
		func = drawPage,
		atag = "writable",
		dirty = false,
	}
	apis.hook = {
		func = hookPage,
		atag = "writable",
		dirty = false,
	}
	return {
		tasks = tasks,
		apis = apis,
		atag = "readonly",
	}
end

return Page
