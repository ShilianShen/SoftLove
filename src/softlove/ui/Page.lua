local util = require("src.util")
local Widget = require("src.ui.Widget")

---@class ui.Page
---@field root ui.Widget
---@field get fun(self: ui.Page, ...: any): table?
local Page = {
	debug = false,
	noise = 0.2,
	target = nil,
}

---@param page ui.Page
local function layoutPage(page, params)
	assert(params ~= nil)
	page.root:layout(params.window, Page)
end

---@param page ui.Page
---@param theme ui.Theme
local function drawPage(page, theme)
	page.root:draw(theme, Page)
end

---@param page ui.Page
local function updatePage(page, params)
	page.root:update(params)
end

---@param page ui.Page
local function focusPage(page, x, y)
	return Widget.focus(page.root, x, y)
end

---@param self ui.Page
local function get(self, ...)
	return Widget.get(self.root, ...)
end

---@param widget ui.Widget
---@param subtasks table<string, softdep.declaration.Task>
---@param apis table<string, softdep.declaration.Api>
---@return softdep.declaration.Node
function Page.Node(widget, subtasks, apis)
	apis = util.copy.deepcopyDAGToTree(apis)
	---@type table<string, softdep.declaration.Task>
	local tasks = util.copy.deepcopyDAGToTree(subtasks)
	local parents_c = {}
	for k, task in pairs(tasks) do
		parents_c[#parents_c + 1] = k
		task.parents_c = task.parents_c or {}
		table.insert(task.parents_c, "_init")
	end
	tasks._init = {
		func = function(self)
			self.root = widget
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
	apis.focus = {
		func = focusPage,
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
