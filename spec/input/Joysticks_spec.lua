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
	end)

	describe("added", function()
		it("should initialize an empty state for the joystick", function()
			Joysticks.added(ctx, joystick)

			local state = ctx.joysticks[1]
			assert.same({}, state.s1)
			assert.same({}, state.s2)
			assert.same({}, state.s3)
			assert.is_function(state.visit)
		end)

		it("should keep joystick states independent", function()
			local other = newJoystick(2)
			Joysticks.added(ctx, joystick)
			Joysticks.added(ctx, other)

			Joysticks.pressed(ctx, joystick, 1)

			assert.is_true(ctx.joysticks[1].s3[1])
			assert.is_nil(ctx.joysticks[2].s3[1])
		end)
	end)

	describe("removed", function()
		it("should remove the joystick state", function()
			Joysticks.added(ctx, joystick)

			Joysticks.removed(ctx, joystick)

			assert.is_nil(ctx.joysticks[1])
		end)
	end)

	describe("update", function()
		it("should update every joystick state", function()
			local other = newJoystick(2)
			Joysticks.added(ctx, joystick)
			Joysticks.added(ctx, other)
			Joysticks.pressed(ctx, joystick, 1)
			Joysticks.axis(ctx, other, "leftx", 0.5)

			Joysticks.update(ctx)

			assert.is_true(ctx.joysticks[1].s2[1])
			assert.equals(0.5, ctx.joysticks[2].s2.leftx)
		end)
	end)

	describe("isDynamic", function()
		it("should return false when there are no joysticks", function()
			assert.is_false(Joysticks.isDynamic(ctx))
		end)

		it("should return false when every joystick state is stable", function()
			Joysticks.added(ctx, joystick)

			assert.is_false(Joysticks.isDynamic(ctx))
		end)

		it("should return true when any joystick state is dynamic", function()
			local other = newJoystick(2)
			Joysticks.added(ctx, joystick)
			Joysticks.added(ctx, other)
			Joysticks.pressed(ctx, other, 1)

			assert.is_true(Joysticks.isDynamic(ctx))
		end)

		it("should return false after a value has propagated", function()
			Joysticks.added(ctx, joystick)
			Joysticks.pressed(ctx, joystick, 1)
			Joysticks.update(ctx)
			Joysticks.update(ctx)

			assert.is_false(Joysticks.isDynamic(ctx))
		end)
	end)

	describe("visit", function()
		it("should return the previous states for the requested joystick ID", function()
			Joysticks.added(ctx, joystick)
			Joysticks.pressed(ctx, joystick, "a")
			Joysticks.update(ctx)

			local s1, s2 = Joysticks.visit(ctx, 1)

			assert.is_nil(s1.a)
			assert.is_true(s2.a)
		end)

		it("should visit joystick states independently", function()
			local other = newJoystick(2)
			Joysticks.added(ctx, joystick)
			Joysticks.added(ctx, other)
			Joysticks.pressed(ctx, other, "b")
			Joysticks.update(ctx)

			local _, first = Joysticks.visit(ctx, 1)
			local _, second = Joysticks.visit(ctx, 2)

			assert.is_nil(first.b)
			assert.is_true(second.b)
		end)
	end)

	describe("pressed", function()
		it("should set the latest button state to true", function()
			Joysticks.added(ctx, joystick)

			Joysticks.pressed(ctx, joystick, "a")

			assert.is_true(ctx.joysticks[1].s3.a)
		end)
	end)

	describe("released", function()
		it("should set the latest button state to false", function()
			Joysticks.added(ctx, joystick)
			Joysticks.pressed(ctx, joystick, "a")

			Joysticks.released(ctx, joystick, "a")

			assert.is_false(ctx.joysticks[1].s3.a)
		end)
	end)

	describe("axis", function()
		it("should set the latest axis value", function()
			Joysticks.added(ctx, joystick)

			Joysticks.axis(ctx, joystick, "leftx", -0.75)

			assert.equals(-0.75, ctx.joysticks[1].s3.leftx)
		end)
	end)

	describe("hat", function()
		it("should set the latest hat direction", function()
			Joysticks.added(ctx, joystick)

			Joysticks.hat(ctx, joystick, 1, "lu")

			assert.equals("lu", ctx.joysticks[1].s3[1])
		end)
	end)
end)
