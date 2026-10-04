local Scope = {}

function Scope:init()
	self.size = 64
	self.memory = {}
	for i = 1, self.size do
		self.memory[i] = 0
	end
end

function Scope:draw(X, Y, W, H)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", X - 1, Y - 1, W + 2, H + 2)

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", X, Y, W, H)

	local max, min
	for t, v in ipairs(self.memory) do
		max = math.max(max or v, v)
		min = math.min(min or v, v)
	end
	local points = {}
	for t, v in ipairs(self.memory) do
		local x = X + W * (t - 0.5) / self.size
		local y = Y + H * (max - v) / (max - min)
		table.insert(points, x)
		table.insert(points, y)
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.line(points)
	love.graphics.print(max, X + W, Y)
	love.graphics.print(min, X + W, Y + H)

	local y0 = Y + H * (max - 0) / (max - min)
	if Y < y0 and y0 < Y + H then
		love.graphics.setColor(1, 0, 0)
		love.graphics.line(X, y0, X + W, y0)
	end
end

function Scope.newNode(target, calculate)
	return {
		tasks = {
			init = {
				func = Scope.init,
				atag = "writable",
				back = false,
			},
			calculate = {
				func = function(self, params)
					for i = 1, self.size - 1 do
						self.memory[i] = self.memory[i + 1]
					end
					local value = calculate(params.target)
					if type(value) == "boolean" then
						value = value and 1 or 0
					end
					self.memory[self.size] = value
				end,
				auto = function(self)
					return true
				end,
				atag = "writable",
				parents_c = { "init" },
				parents_d = { target = target },
				back = false,
			},
		},
		apis = {
			draw = { func = Scope.draw, atag = "writable", dirty = false },
		},
		atag = "none",
	}
end

return Scope
