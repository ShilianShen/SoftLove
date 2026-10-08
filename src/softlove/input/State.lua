---@alias softlove.input.SignalKey string|integer

---@class softlove.input.State
---@field s1 table<softlove.input.SignalKey, any>
---@field s2 table<softlove.input.SignalKey, any>
---@field s1const table<softlove.input.SignalKey, any>
---@field s2const table<softlove.input.SignalKey, any>
---@field visit function
local State = {}

local function const(t)
	return setmetatable({}, {
		__index = t,
		__newindex = false,
		__metatable = false,
	})
end

function State:init()
	self.s1 = {}
	self.s2 = {}
	self.s1const = const(self.s1)
	self.s2const = const(self.s2)
	self.visit = State.visit
end

function State:step()
	for signal, _ in pairs(self.s2) do
		self.s1[signal] = self.s2[signal]
	end
end

---@param key softlove.input.SignalKey
---@param value any
function State:set(key, value)
	self.s2[key] = value
end

function State:visit()
	return self.s1const, self.s2const
end

return State
