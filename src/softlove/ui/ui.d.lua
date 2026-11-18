---@meta

---The application defines the theme structure; draw passes it unchanged to each widget's _draw.
---@alias softlove.ui.Theme table

---The resulting layout area; the specific _layout implementation determines its coordinates.
---@class softlove.ui.Bounds
---@field x number
---@field y number
---@field w number
---@field h number

---@class softlove.ui.BoundsPatch
---@field x? number
---@field y? number
---@field w? number
---@field h? number

---Optional overrides for widget types and instances; see WidgetType for precedence and copying rules.
---Table fields are replaced as a whole except bounds, which merges coordinates; userData, loveData and children are not merged recursively.
---userData holds application inputs and operations; loveData holds derived display data and caches. Each widget defines their contents.
---Construction copies tables; runtime callbacks use the instance's actual tables. This separation does not enforce private or read-only access.
---_update and _draw do not receive self; self in _layout, _hook and inside is the Widget.
---Normally implement underscore callbacks; overriding layout/draw/update/hook/sort replaces the corresponding default traversal logic.
---@class softlove.ui.Patch
---@field bounds? softlove.ui.BoundsPatch
---@field depth? number
---@field visible? boolean
---@field active? boolean
---@field userData? table Application inputs and methods, e.g. widget.userData:setValue(v); self in such methods is this table.
---@field loveData? table Internal derived data and caches, normally computed in _update and read in _layout and _draw.
---@field inside? fun(self: softlove.ui.Widget, x: number, y: number): boolean Additional hit test within bounds.
---@field children? table<any, softlove.ui.Widget> Existing Widget instances when constructing types or instances directly.
---@field _draw? fun(userData: table, loveData: table, bounds: softlove.ui.Bounds, themes: softlove.ui.Theme) Receives original references to this widget's data tables, layout result and theme.
---@field _layout? fun(self: softlove.ui.Widget, bounds: softlove.ui.Bounds) Reads the parent's area and writes the layout result to self.bounds.
---@field _update? fun(userData: table, loveData: table, params: table, children: table<any, table>) children[key] references a direct child's userData, not its Widget.
---@field _hook? fun(self: softlove.ui.Widget, x: number, y: number): table Extra information after a hit; does not select the hit Widget.
---@field layout? fun(self: softlove.ui.Widget, bounds: softlove.ui.Bounds)
---@field sort? fun(self: softlove.ui.Widget)
---@field draw? fun(self: softlove.ui.Widget, theme: softlove.ui.Theme)
---@field update? fun(self: softlove.ui.Widget, params: table)
---@field hook? fun(self: softlove.ui.Widget, x: number, y: number): softlove.ui.Widget?, table?

---A named declaration for the Widgets registry; type references a name in the same registry, and children contains recursive declarations.
---Unlike Patch, children contains declarations to build rather than existing Widget instances.
---Only fields declared here or in Patch are accepted; initialization rejects unknown fields recursively. Put custom content in data tables.
---@class softlove.ui.WidgetTypeDeclaration: softlove.ui.Patch
---@field type? string
---@field children? table<any, softlove.ui.WidgetTypeDeclaration>
