local State = {}

---@param signals table<any, any>
function State:init(signals)
	for i = 1, 3 do
		local s = "s" .. i
		self[s] = {}
		for signal, value in pairs(signals) do
			self[s][signal] = value
		end
	end
end

function State:update()
	for signal, _ in pairs(self.s1) do
		self.s1[signal] = self.s2[signal]
		self.s2[signal] = self.s3[signal]
	end
end

function State:isDynamic()
	for signal, _ in pairs(self.s1) do
		local s1 = self.s1[signal]
		local s2 = self.s2[signal]
		local s3 = self.s3[signal]
		if s1 ~= s2 or s2 ~= s3 then
			return true
		end
	end
	return false
end

return State
