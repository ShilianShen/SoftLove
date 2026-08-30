local scope = {
	channels = {},
	windowSize = 10,
}

function scope:newChannel(tag)
	local channel = {}
	for i = 1, self.windowSize do
		channel[i] = 0
	end
	self.channels[tag] = channel
end

function scope:update(tag, value)
	if self.channels[tag] == nil then
		self:newChannel(tag)
	end
	table.remove(self.channels[tag], 1)
	self.channels[tag][self.windowSize] = value
end

function scope:draw()
	local X, Y = 0, 0
	local W, H = love.graphics.getDimensions()
	local font = love.graphics.getFont()
	local tagW = 0
	local N = 0
	for tag, channel in pairs(self.channels) do
		tagW = math.max(tagW, font:getWidth(tag))
		N = N + 1
	end
	local M = 2 * N + 1
end

return scope
