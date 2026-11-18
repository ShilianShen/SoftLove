---@meta

---Theme contents are defined by the application and passed through unchanged.
---@alias softlove.ui.Theme table

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

---Optional overrides accepted by WidgetType construction and instantiation.
---@class softlove.ui.Patch
---@field bounds? softlove.ui.BoundsPatch
---@field depth? number
---@field visible? boolean
---@field active? boolean
---@field userData? table User-provided inputs.
---@field loveData? table Data derived for rendering.
---@field inside? fun(self: softlove.ui.Widget, x: number, y: number): boolean
---@field children? table<any, softlove.ui.Widget>
---@field _draw? fun(userData: table, loveData: table, bounds: softlove.ui.Bounds, themes: softlove.ui.Theme)
---@field _layout? fun(self: softlove.ui.Widget, bounds: softlove.ui.Bounds)
---@field _update? fun(userData: table, loveData: table, params: table, children: table<any, table>)
---@field _hook? fun(self: softlove.ui.Widget, x: number, y: number): table
---@field layout? fun(self: softlove.ui.Widget, bounds: softlove.ui.Bounds)
---@field sort? fun(self: softlove.ui.Widget)
---@field draw? fun(self: softlove.ui.Widget, theme: softlove.ui.Theme)
---@field update? fun(self: softlove.ui.Widget, params: table)
---@field hook? fun(self: softlove.ui.Widget, x: number, y: number): softlove.ui.Widget?, table?

---Named declarations use type names and recursively declared children.
---Only fields declared here or inherited from Patch are accepted; unknown fields raise an error.
---@class softlove.ui.WidgetTypeDeclaration: softlove.ui.Patch
---@field type? string
---@field children? table<any, softlove.ui.WidgetTypeDeclaration>
