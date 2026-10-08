package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local Wheel = require("softlove.input.Wheel")

describe("Wheel", function()
	local ctx

	before_each(function()
		ctx = {}
		Wheel.init(ctx)
	end)

	describe("init", function()
		it("should initialize two empty wheel states", function()
			assert.same({}, ctx.s1)
			assert.same({}, ctx.s2)
		end)

		it("should create independent wheel states", function()
			Wheel.moved(ctx, 10, 0)

			assert.is_nil(ctx.s1.dx)
			assert.equals(10, ctx.s2.dx)
		end)

		it("should expose get function", function()
			assert.is_function(ctx.get)
		end)
	end)

	describe("get", function()
		it("should return previous and current wheel deltas", function()
			Wheel.moved(ctx, 10, -5)

			local previousDx, currentDx = ctx:get("dx")
			local previousDy, currentDy = ctx:get("dy")
			assert.is_nil(previousDx)
			assert.equals(10, currentDx)
			assert.is_nil(previousDy)
			assert.equals(-5, currentDy)

			Wheel.step(ctx)
			Wheel.moved(ctx, -2, 3)
			previousDx, currentDx = ctx:get("dx")
			previousDy, currentDy = ctx:get("dy")

			assert.equals(10, previousDx)
			assert.equals(-2, currentDx)
			assert.equals(-5, previousDy)
			assert.equals(3, currentDy)
		end)
	end)

	describe("moved", function()
		it("should update the latest wheel delta", function()
			Wheel.moved(ctx, 10, -5)

			assert.equals(10, ctx.s2.dx)
			assert.equals(-5, ctx.s2.dy)
		end)

		it("should allow replacing the latest wheel delta", function()
			Wheel.moved(ctx, 10, -5)
			Wheel.moved(ctx, -2, 3)

			assert.equals(-2, ctx.s2.dx)
			assert.equals(3, ctx.s2.dy)
		end)

		it("should keep previous wheel states unchanged", function()
			Wheel.moved(ctx, 10, -5)

			assert.same({}, ctx.s1)
		end)
	end)
end)
