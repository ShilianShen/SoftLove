local util = require("softlove.ui.util")
local Widget = require("softlove.ui.Widget")

---@class softlove.ui.Page
---@field entry softlove.ui.Widget
---@field ui boolean
local Page = {}

---@param params { window: softlove.ui.Bounds }
function Page:layout(params)
	assert(params ~= nil)
	self.entry:layout(params.window)
end

function Page:sort()
	self.entry:sort()
end

---@param theme softlove.ui.Theme
function Page:draw(theme)
	self.entry:draw(theme)
end

---@param params table
function Page:update(params)
	self.entry:update(params)
end

---@param x number
---@param y number
function Page:hook(x, y)
	return self.entry:hook(x, y)
end

---@param ... any
function Page:get(...)
	return Widget.get(self.entry, ...)
end

---User subtasks must assign self.entry before _sort runs.
---@param subtasks table<string, softdep.declaration.Task>
---@param apis table<string, softdep.declaration.Api>
---@return softdep.declaration.Node
return function(subtasks, apis)
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
			self.get = Page.get
			self.ui = true
		end,
		atag = "writable",
		back = false,
	}
	tasks._sort = {
		func = Page.sort,
		parents_c = parents_c,
		parents_d = { fonts = "fonts", locales = "locales" },
		atag = "writable",
		back = false,
	}
	tasks._update = {
		func = Page.update,
		parents_c = { "_sort" },
		parents_d = { fonts = "fonts", locales = "locales" },
		atag = "writable",
		back = false,
	}
	tasks._layout = {
		func = Page.layout,
		parents_d = { window = "window" },
		parents_c = { "_update" },
		atag = "writable",
		back = false,
	}
	apis.draw = {
		func = Page.draw,
		atag = "writable",
		dirty = false,
	}
	apis.hook = {
		func = Page.hook,
		atag = "writable",
		dirty = false,
	}
	return {
		tasks = tasks,
		apis = apis,
		atag = "readonly",
	}
end
