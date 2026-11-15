---@class softlove.ui.Theme

---@class softlove.ui.Bounds
---@field x number
---@field y number
---@field w number
---@field h number

---@class softlove.ui.BorderPatch
---@field x? number
---@field y? number
---@field w? number
---@field h? number

---@class softlove.ui.Patch
---@field border? softlove.ui.BorderPatch
---@field z? number
---@field visible? boolean
---@field ["public"]? boolean
---@field active? boolean
---@field userData? table<string, any> User-provided inputs.
---@field loveData? table<string, any> Data derived for rendering.
---@field setter? table<string, fun(self: softlove.ui.Widget, ...): ...>
---@field inside? fun(self: softlove.ui.Widget, x: number, y: number): boolean
---@field children? table<any, softlove.ui.Widget>
---@field _draw? fun(self: softlove.ui.Widget, theme: softlove.ui.Theme)
---@field _layout? fun(self: softlove.ui.Widget, parent: softlove.ui.Bounds)
---@field _update? fun(self: softlove.ui.Widget, params: table<string, table>)
---@field _hook? fun(self: softlove.ui.Widget, x: number, y: number): softlove.ui.Widget?, table?
---@field hooked? fun(self: softlove.ui.Widget): table

---@class softlove.ui.WidgetTypeDeclaration: softlove.ui.Patch
---@field type? string
---@field children? table<any, softlove.ui.WidgetTypeDeclaration>
