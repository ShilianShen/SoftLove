local softdep = require("libs.softdep_local")
local mouse = require("src.softlove.devices.mouse")
local keyboard = require("src.softlove.devices.keyboard")

local devices = {
	mouse = softdep.newNode(
		mouse,
		{
			init = { func = mouse.init },
			update = { func = mouse.update, parents_c = { "init" }, auto = mouse.dynamic },
		},
		nil,
		{
			update = { task = "update" },
		}
	),
	keyboard = softdep.newNode(
		keyboard,
		{
			init = { func = keyboard.init },
			update = { func = keyboard.update, parents_c = { "init" }, auto = keyboard.dynamic },
		},
		nil,
		{
			update = { func = keyboard.newKey, task = "update" },
		}
	),
}

function love.mousemoved(...)
	devices.mouse.api.update()
end

function love.mousepressed(...)
	devices.mouse.api.update()
end

function love.mousereleased(...)
	devices.mouse.api.update()
end

function love.keypressed(key)
	devices.keyboard.api.update(key)
end

function love.keyreleased(key)
	devices.keyboard.api.update(key)
end

return devices
