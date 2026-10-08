---@class softlove.input.State<K>
---@field s1 table<K, any>
---@field s2 table<K, any>
---@field get fun(self: softlove.input.State<K>, key: K): any, any

local State = {}

---@param self table
function State.init(self)
	self.s1 = {}
	self.s2 = {}
	self.get = State.get
end

---@generic K
---@param self softlove.input.State<K>
function State.step(self)
	for signal, _ in pairs(self.s2) do
		self.s1[signal] = self.s2[signal]
	end
end

---@generic K
---@param self softlove.input.State<K>
---@param key K
---@param value any
function State.set(self, key, value)
	self.s2[key] = value
end

---@generic K
---@param self softlove.input.State<K>
---@param key K
---@return any, any
function State.get(self, key)
	return self.s1[key], self.s2[key]
end

return State
