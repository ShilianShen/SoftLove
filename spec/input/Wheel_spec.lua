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
		it("should initialize three wheel states", function()
			local expected = {
				dx = 0,
				dy = 0,
			}

			assert.same(expected, ctx.s1)
			assert.same(expected, ctx.s2)
			assert.same(expected, ctx.s3)
		end)

		it("should create independent wheel states", function()
			ctx.s3.dx = 10

			assert.equals(0, ctx.s1.dx)
			assert.equals(0, ctx.s2.dx)
			assert.equals(10, ctx.s3.dx)
		end)

		it("should expose visit function", function()
			assert.is_function(ctx.visit)
		end)
	end)

	describe("moved", function()
		it("should update the latest wheel delta", function()
			Wheel.moved(ctx, 10, -5)

			assert.equals(10, ctx.s3.dx)
			assert.equals(-5, ctx.s3.dy)
		end)

		it("should allow replacing the latest wheel delta", function()
			Wheel.moved(ctx, 10, -5)
			Wheel.moved(ctx, -2, 3)

			assert.equals(-2, ctx.s3.dx)
			assert.equals(3, ctx.s3.dy)
		end)

		it("should keep previous wheel states unchanged", function()
			Wheel.moved(ctx, 10, -5)

			assert.same({ dx = 0, dy = 0 }, ctx.s1)
			assert.same({ dx = 0, dy = 0 }, ctx.s2)
		end)
	end)
end)
