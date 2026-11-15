---@class softlove.ui.Theme

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

---@class softlove.ui.Patch
---@field bounds? softlove.ui.BoundsPatch
---@field z? number
---@field visible? boolean
---@field ["public"]? boolean
---@field active? boolean
---@field userData? table User-provided inputs.
---@field loveData? table Data derived for rendering.
---@field setter? table<string, fun(self: softlove.ui.Widget, ...): ...>
---@field inside? fun(self: softlove.ui.Widget, x: number, y: number): boolean
---@field children? table<any, softlove.ui.Widget>
---@field _draw? fun(userData: table, loveData: table, bounds: softlove.ui.Bounds, themes: softlove.ui.Theme)
---@field _layout? fun(self: softlove.ui.Widget, bounds: softlove.ui.Bounds)
---@field _update? fun(userData: table, loveData: table, params: table<string, table>)
---@field _hook? fun(self: softlove.ui.Widget, x: number, y: number): softlove.ui.Widget?, table?
---@field hooked? fun(self: softlove.ui.Widget): table

---@class softlove.ui.WidgetTypeDeclaration: softlove.ui.Patch
---@field type? string
---@field children? table<any, softlove.ui.WidgetTypeDeclaration>
