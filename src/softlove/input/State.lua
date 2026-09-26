local State = {}

local function const(t)
	return setmetatable({}, {
		__index = t,
		__newindex = false,
		__metatable = false,
	})
end

local sis = { "s1", "s2", "s3" }

---@param signals table<any, "number"|"boolean">
function State:init(signals)
	for _, si in ipairs(sis) do
		self[si] = {}
		for signal, value in pairs(signals) do
			self[si][signal] = value
		end
	end
	self.visit = State.visit
	self.s1const = const(self.s1)
	self.s2const = const(self.s2)
end

function State:update()
	for signal, _ in pairs(self.s3) do
		self.s1[signal] = self.s2[signal]
		self.s2[signal] = self.s3[signal]
	end
end

function State:isDynamic()
	for signal, _ in pairs(self.s3) do
		local s1 = self.s1[signal]
		local s2 = self.s2[signal]
		local s3 = self.s3[signal]
		if s1 ~= s2 or s2 ~= s3 then
			return true
		end
	end
	return false
end

---@param signal string
---@param value any
function State:set(signal, value)
	self.s3[signal] = value
end

function State:visit()
	return self.s1const, self.s2const
end

return State
