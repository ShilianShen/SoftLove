---@alias softlove.input.VisitFn<T> fun(self: softlove.input.State<T>): table<T, any>, table<T, any>

---@class softlove.input.State<T>
---@field s1 table<T, any>
---@field s2 table<T, any>
---@field s1const table<T, any>
---@field s2const table<T, any>
---@field visit softlove.input.VisitFn<T>

local State = {}

local function const(t)
	return setmetatable({}, {
		__index = t,
		__newindex = false,
		__metatable = false,
	})
end

---@param self table
function State.init(self)
	self.s1 = {}
	self.s2 = {}
	self.s1const = const(self.s1)
	self.s2const = const(self.s2)
	self.visit = State.visit
end

---@generic T
---@param self softlove.input.State<T>
function State.step(self)
	for signal, _ in pairs(self.s2) do
		self.s1[signal] = self.s2[signal]
	end
end

---@generic T
---@param self softlove.input.State<T>
---@param key T
---@param value any
function State.set(self, key, value)
	self.s2[key] = value
end

---@generic T
---@param self softlove.input.State<T>
---@return table<T, any>, table<T, any>
function State.visit(self)
	return self.s1const, self.s2const
end

return State
