local softlove = {
	util = require("softlove.util"),
	ui = require("softlove.ui"),
	input = require("softlove.input"),
	system = require("softlove.system"),
	assets = require("softlove.assets"),
}

function softlove.setCallbacks(nodes)
	if nodes.window then
		love.focus = nodes.window.apis.focus
		love.resize = nodes.window.apis.resize
		love.visible = nodes.window.apis.visible
	end

	if nodes.joysticks then
		love.joystickadded = nodes.joysticks.apis.added
		love.joystickremoved = nodes.joysticks.apis.removed
		love.joystickpressed = nodes.joysticks.apis.pressed
		love.joystickreleased = nodes.joysticks.apis.released
		love.joystickaxis = nodes.joysticks.apis.axis
		love.joystickhat = nodes.joysticks.apis.hat
		love.gamepadpressed = nodes.joysticks.apis.pressed
		love.gamepadreleased = nodes.joysticks.apis.released
		love.gamepadaxis = nodes.joysticks.apis.axis
	end

	if nodes.mouse then
		love.mousemoved = nodes.mouse.apis.moved
		love.mousepressed = nodes.mouse.apis.pressed
		love.mousereleased = nodes.mouse.apis.released
		love.mousefocus = nodes.mouse.apis.focus
	end

	if nodes.keyboard then
		love.keypressed = nodes.keyboard.apis.pressed
		love.keyreleased = nodes.keyboard.apis.released
	end

	if nodes.wheel then
		love.wheelmoved = nodes.wheel.apis.moved
	end
end

return softlove
