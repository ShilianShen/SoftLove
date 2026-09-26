package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local Joystick = require("softlove.input.Joystick")

describe("Joystick", function()
	local ctx
	local joystick

	before_each(function()
		ctx = {}
		joystick = {}
		Joystick.init(ctx)
	end)

	describe("init", function()
		it("should initialize an empty joystick collection", function()
			assert.same({}, ctx.joysticks)
		end)
	end)

	describe("added", function()
		it("should initialize an empty state for the joystick", function()
			Joystick.added(ctx, joystick)

			local state = ctx.joysticks[joystick]
			assert.same({}, state.s1)
			assert.same({}, state.s2)
			assert.same({}, state.s3)
			assert.is_function(state.visit)
		end)

		it("should keep joystick states independent", function()
			local other = {}
			Joystick.added(ctx, joystick)
			Joystick.added(ctx, other)

			Joystick.pressed(ctx, joystick, 1)

			assert.is_true(ctx.joysticks[joystick].s3[1])
			assert.is_nil(ctx.joysticks[other].s3[1])
		end)
	end)

	describe("removed", function()
		it("should remove the joystick state", function()
			Joystick.added(ctx, joystick)

			Joystick.removed(ctx, joystick)

			assert.is_nil(ctx.joysticks[joystick])
		end)
	end)

	describe("update", function()
		it("should update every joystick state", function()
			local other = {}
			Joystick.added(ctx, joystick)
			Joystick.added(ctx, other)
			Joystick.pressed(ctx, joystick, 1)
			Joystick.axis(ctx, other, "leftx", 0.5)

			Joystick.update(ctx)

			assert.is_true(ctx.joysticks[joystick].s2[1])
			assert.equals(0.5, ctx.joysticks[other].s2.leftx)
		end)
	end)

	describe("isDynamic", function()
		it("should return false when there are no joysticks", function()
			assert.is_false(Joystick.isDynamic(ctx))
		end)

		it("should return false when every joystick state is stable", function()
			Joystick.added(ctx, joystick)

			assert.is_false(Joystick.isDynamic(ctx))
		end)

		it("should return true when any joystick state is dynamic", function()
			local other = {}
			Joystick.added(ctx, joystick)
			Joystick.added(ctx, other)
			Joystick.pressed(ctx, other, 1)

			assert.is_true(Joystick.isDynamic(ctx))
		end)

		it("should return false after a value has propagated", function()
			Joystick.added(ctx, joystick)
			Joystick.pressed(ctx, joystick, 1)
			Joystick.update(ctx)
			Joystick.update(ctx)

			assert.is_false(Joystick.isDynamic(ctx))
		end)
	end)

	describe("pressed", function()
		it("should set the latest button state to true", function()
			Joystick.added(ctx, joystick)

			Joystick.pressed(ctx, joystick, "a")

			assert.is_true(ctx.joysticks[joystick].s3.a)
		end)
	end)

	describe("released", function()
		it("should set the latest button state to false", function()
			Joystick.added(ctx, joystick)
			Joystick.pressed(ctx, joystick, "a")

			Joystick.released(ctx, joystick, "a")

			assert.is_false(ctx.joysticks[joystick].s3.a)
		end)
	end)

	describe("axis", function()
		it("should set the latest axis value", function()
			Joystick.added(ctx, joystick)

			Joystick.axis(ctx, joystick, "leftx", -0.75)

			assert.equals(-0.75, ctx.joysticks[joystick].s3.leftx)
		end)
	end)

	describe("hat", function()
		it("should set the latest hat direction", function()
			Joystick.added(ctx, joystick)

			Joystick.hat(ctx, joystick, 1, "lu")

			assert.equals("lu", ctx.joysticks[joystick].s3[1])
		end)
	end)
end)
