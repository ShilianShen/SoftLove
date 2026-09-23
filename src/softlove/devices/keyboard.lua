local keyboard = {
	read = {},
	write = {},
}

function keyboard.init(self)
	self.buttons = {}
	self.isDown1 = {}
	self.isDown2 = {}
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = false
		self.isDown2[bt] = false
	end
end

function keyboard.update(self, key)
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
		self.isDown2[bt] = love.keyboard.isDown(bt)
	end
end

function keyboard.dynamic(self)
	for _, bt in pairs(self.buttons) do
		if self.isDown1[bt] ~= self.isDown2[bt] then
			return true
		end
	end
	return false
end

function keyboard.write.newKey(self, key)
	if self.isDown2[key] == nil then
		table.insert(self.buttons, key)
	end
end

return keyboard
