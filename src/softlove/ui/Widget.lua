---Each widget owns its inputs, rendering data and subtree; see WidgetType for construction-time copying rules.
---Application code maintains inputs and operations in userData; the widget maintains derived display data or caches in loveData.
---Typical flow: application changes userData -> _update computes loveData and child inputs -> _layout -> _draw.
---This separates responsibilities: both are ordinary mutable tables, accessible through the Widget without private or read-only proxies.
---_update and _draw are plain function calls without a Widget argument; _layout, _hook and inside receive the full instance via colon calls.
---@class softlove.ui.Widget
---@field bounds softlove.ui.Bounds This widget's layout result; _layout should update this table.
---@field depth number Larger values are deeper; siblings are traversed in descending order, drawing shallower widgets later.
---@field visible boolean false skips only this widget's drawing and hit testing; children, updates and layout are unaffected.
---@field active boolean false skips updates, layout, drawing and hit testing for the entire subtree; external code must reactivate it.
---@field userData table Application inputs and methods, e.g. widget.userData:setValue(v); self in such methods is userData.
---@field loveData table Internal derived display data and caches used by _update, _layout, _draw, etc.; never cleared automatically.
---@field children table<any, softlove.ui.Widget> Actual child widgets, indexed by names or other keys.
---@field order softlove.ui.Widget[] Child traversal cache built by sort; entries reference instances in children.
---@field _layout fun(self: softlove.ui.Widget, bounds: softlove.ui.Bounds) bounds is the parent's area; the root receives the Page's window area.
---@field _draw fun(userData: table, loveData: table, bounds: softlove.ui.Bounds, themes: softlove.ui.Theme) Plain function receiving this widget's data and layout result.
---@field _update fun(userData: table, loveData: table, params: table, children: table<any, table>) Plain function; children maps keys to child userData tables.
---@field _hook fun(self: softlove.ui.Widget, x: number, y: number): table Supplies extra information after a hit; hook returns the hit Widget.
---@field inside fun(self: softlove.ui.Widget, x: number, y: number): boolean Additional hit test within bounds.
local Widget = {}

local function compare(widget1, widget2)
	return widget1.depth > widget2.depth
end

---Lay out this widget first, then pass its bounds to children; child layout order does not depend on depth.
---bounds references the input area; write the layout result to self.bounds to avoid changing the parent's area.
---@param bounds softlove.ui.Bounds
function Widget:layout(bounds)
	if self.active then
		self:_layout(bounds)
		for _, child in pairs(self.children) do
			child:layout(self.bounds)
		end
	end
end

---Rebuild order recursively, including inactive subtrees; ordering among equal depths is unspecified.
---Call again after changing children or depth; draw/update/hook do not refresh the cache automatically.
function Widget:sort()
	self.order = {}
	for _, child in pairs(self.children) do
		self.order[#self.order + 1] = child
	end
	table.sort(self.order, compare)
	for _, child in ipairs(self.order) do
		child:sort()
	end
end

---Draw this widget first, then subtrees in order. _draw receives the existing data tables; loveData is neither copied nor cleared.
---theme is passed unchanged throughout the subtree; _update normally prepares derived rendering data beforehand.
---@param theme softlove.ui.Theme
function Widget:draw(theme)
	if self.active then
		if self.visible then
			self._draw(self.userData, self.loveData, self.bounds, theme)
		end
		for _, child in ipairs(self.order) do
			child:draw(theme)
		end
	end
end

---Update this widget first, then subtrees in order, so children can read inputs assigned by the parent in the same pass.
---userData and loveData are this widget's actual tables; params is passed unchanged throughout the subtree without copying.
---A fresh children map exposes only direct children's userData, not their Widget fields such as loveData, bounds or active.
---For example, children.label.text = "new value" changes the actual input; children.label = {} only replaces a temporary map entry.
---Runtime assignments still share table references: children.label.options = userData.options does not make a deep copy.
---Change subtree structure or Widget fields such as active through page tasks or APIs that hold the Widget instance.
---@param params table
function Widget:update(params)
	if self.active then
		local children = {}
		for k, v in pairs(self.children) do
			children[k] = v.userData
		end
		self._update(self.userData, self.loveData, params, children)
		for _, child in ipairs(self.order) do
			child:update(params)
		end
	end
end

---Call this widget's _hook only when coordinates lie strictly within bounds (excluding edges) and pass inside.
---Invisible or missed parents do not block child hit tests; later hits replace earlier results and overwrite matching information keys.
---@param x number
---@param y number
---@return softlove.ui.Widget? widget
---@return table? information
function Widget:hook(x, y)
	if self.active then
		local result
		local information = {}
		if
			self.visible
			and self.bounds.x < x
			and x < self.bounds.x + self.bounds.w
			and self.bounds.y < y
			and y < self.bounds.y + self.bounds.h
			and self:inside(x, y)
		then
			result = self
			for k, v in pairs(self:_hook(x, y) or {}) do
				information[k] = v
			end
		end
		for _, child in ipairs(self.order) do
			local childResult, childHooks = child:hook(x, y)
			result = childResult or result
			for k, v in pairs(childHooks or {}) do
				information[k] = v
			end
		end
		if result then
			return result, information
		end
	end
end

return Widget
