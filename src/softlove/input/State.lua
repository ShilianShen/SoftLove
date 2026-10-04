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
	self.visit = State.visit
	self.s1const = const(self.s1)
	self.s2const = const(self.s2)
	self.isDynamic = State.isDynamic
end

function State:step()
	for signal, _ in pairs(self.s2) do
		self.s1[signal] = self.s2[signal]
	end
end

function State:isDynamic()
	for signal, _ in pairs(self.s2) do
		local s1 = self.s1[signal]
		local s2 = self.s2[signal]
		if s1 ~= s2 then
			return true
		end
	end
	return false
end

---@param signal string
---@param value any
function State:set(signal, value)
	self.s2[signal] = value
end

function State:visit()
	return self.s1const, self.s2const
end

return State
