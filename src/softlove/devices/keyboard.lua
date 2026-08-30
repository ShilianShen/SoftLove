local keyboard = {
	buttons = {},
}

function keyboard:init()
	self.isDown1 = {}
	self.isDown2 = {}
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = false
		self.isDown2[bt] = false
	end
end

function keyboard:update(key)
	for _, bt in pairs(self.buttons) do
		self.isDown1[bt] = self.isDown2[bt]
		self.isDown2[bt] = love.keyboard.isDown(bt)
	end
end

function keyboard:dynamic()
	for _, bt in pairs(self.buttons) do
		if self.isDown1[bt] ~= self.isDown2[bt] then
			return true
		end
	end
	return false
end

function keyboard.newKey(key)
	if keyboard.isDown2[key] == nil then
		table.insert(keyboard.buttons, key)
	end
end

return keyboard
