package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local Joysticks = require("softlove.input.Joysticks")

local function newJoystick(id)
	return {
		getID = function()
			return id
		end,
	}
end

describe("Joystick", function()
	local ctx
	local joystick

	before_each(function()
		ctx = {}
		joystick = newJoystick(1)
		Joysticks.init(ctx)
	end)

	describe("init", function()
		it("should initialize an empty joystick collection", function()
			assert.same({}, ctx.joysticks)
		end)

		it("should expose get function", function()
			assert.equals(Joysticks.get, ctx.get)
		end)
	end)

	describe("added", function()
		it("should initialize an empty state for the joystick", function()
			Joysticks.added(ctx, joystick)

			local state = ctx.joysticks[1]
			assert.same({}, state.s1)
			assert.same({}, state.s2)
			assert.is_function(state.get)
		end)

		it("should keep joystick states independent", function()
			local other = newJoystick(2)
			Joysticks.added(ctx, joystick)
			Joysticks.added(ctx, other)

			Joysticks.pressed(ctx, joystick, 1)

			assert.is_true(ctx.joysticks[1].s2[1])
			assert.is_nil(ctx.joysticks[2].s2[1])
		end)
	end)

	describe("removed", function()
		it("should remove the joystick state", function()
			Joysticks.added(ctx, joystick)

			Joysticks.removed(ctx, joystick)

			assert.is_nil(ctx.joysticks[1])
		end)
	end)

	describe("step", function()
		it("should update every joystick state", function()
			local other = newJoystick(2)
			Joysticks.added(ctx, joystick)
			Joysticks.added(ctx, other)
			Joysticks.pressed(ctx, joystick, 1)
			Joysticks.axis(ctx, other, "leftx", 0.5)

			Joysticks.step(ctx)

			assert.is_true(ctx.joysticks[1].s2[1])
			assert.equals(0.5, ctx.joysticks[2].s2.leftx)
		end)
	end)

	describe("get", function()
		it("should return the previous and current values for the requested joystick", function()
			Joysticks.added(ctx, joystick)
			Joysticks.pressed(ctx, joystick, "a")

			local previous, current = ctx:get(1, "a")

			assert.is_nil(previous)
			assert.is_true(current)
		end)

		it("should read joystick states independently", function()
			local other = newJoystick(2)
			Joysticks.added(ctx, joystick)
			Joysticks.added(ctx, other)
			Joysticks.pressed(ctx, other, "b")

			local _, first = ctx:get(1, "b")
			local _, second = ctx:get(2, "b")

			assert.is_nil(first)
			assert.is_true(second)
		end)

		it("should return nil values for an unknown joystick", function()
			local previous, current = ctx:get(99, "a")

			assert.is_nil(previous)
			assert.is_nil(current)
		end)

		it("should return previous and current values after stepping", function()
			Joysticks.added(ctx, joystick)
			Joysticks.axis(ctx, joystick, "leftx", 0.5)
			Joysticks.step(ctx)
			Joysticks.axis(ctx, joystick, "leftx", -0.75)

			local previous, current = ctx:get(1, "leftx")

			assert.equals(0.5, previous)
			assert.equals(-0.75, current)
		end)
	end)

	describe("pressed", function()
		it("should set the latest button state to true", function()
			Joysticks.added(ctx, joystick)

			Joysticks.pressed(ctx, joystick, "a")

			assert.is_true(ctx.joysticks[1].s2.a)
		end)
	end)

	describe("released", function()
		it("should set the latest button state to false", function()
			Joysticks.added(ctx, joystick)
			Joysticks.pressed(ctx, joystick, "a")

			Joysticks.released(ctx, joystick, "a")

			assert.is_false(ctx.joysticks[1].s2.a)
		end)
	end)

	describe("axis", function()
		it("should set the latest axis value", function()
			Joysticks.added(ctx, joystick)

			Joysticks.axis(ctx, joystick, "leftx", -0.75)

			assert.equals(-0.75, ctx.joysticks[1].s2.leftx)
		end)
	end)

	describe("hat", function()
		it("should set the latest hat direction", function()
			Joysticks.added(ctx, joystick)

			Joysticks.hat(ctx, joystick, 1, "lu")

			assert.equals("lu", ctx.joysticks[1].s2[1])
		end)
	end)
end)
