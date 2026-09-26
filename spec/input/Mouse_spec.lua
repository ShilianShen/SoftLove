package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local Mouse = require("softlove.input.Mouse")

describe("Mouse", function()
	local ctx

	before_each(function()
		ctx = {}
		Mouse.init(ctx)
	end)

	describe("init", function()
		it("should initialize three empty mouse states", function()
			assert.same({}, ctx.s1)
			assert.same({}, ctx.s2)
			assert.same({}, ctx.s3)
		end)

		it("should create independent mouse states", function()
			Mouse.pressed(ctx, 10, 20, 1, false, 1)
			Mouse.moved(ctx, 10, 20, 10, 20, false)

			assert.is_nil(ctx.s1[1])
			assert.is_nil(ctx.s2[1])
			assert.is_nil(ctx.s1.x)
			assert.is_nil(ctx.s2.x)
		end)

		it("should expose visit function", function()
			assert.is_function(ctx.visit)
		end)
	end)

	describe("pressed", function()
		it("should mark the pressed button as down", function()
			Mouse.pressed(ctx, 10, 20, 2, false, 1)

			assert.is_true(ctx.s3[2])
		end)

		it("should not change other buttons", function()
			Mouse.pressed(ctx, 10, 20, 2, false, 1)

			assert.is_nil(ctx.s3[1])
			assert.is_nil(ctx.s3[3])
		end)
	end)

	describe("released", function()
		it("should mark the released button as up", function()
			Mouse.pressed(ctx, 10, 20, 2, false, 1)

			Mouse.released(ctx, 10, 20, 2, false, 1)

			assert.is_false(ctx.s3[2])
		end)

		it("should not change other buttons", function()
			ctx.s3[1] = true
			ctx.s3[2] = true

			Mouse.released(ctx, 10, 20, 2, false, 1)

			assert.is_true(ctx.s3[1])
			assert.is_false(ctx.s3[2])
		end)
	end)

	describe("moved", function()
		it("should update the latest mouse position", function()
			Mouse.moved(ctx, 100, 200, 10, 20, false)

			assert.equals(100, ctx.s3.x)
			assert.equals(200, ctx.s3.y)
		end)

		it("should allow replacing the latest mouse position", function()
			Mouse.moved(ctx, 100, 200, 10, 20, false)
			Mouse.moved(ctx, 300, 400, 200, 200, false)

			assert.equals(300, ctx.s3.x)
			assert.equals(400, ctx.s3.y)
		end)
	end)

	describe("focus", function()
		it("should update focus state", function()
			Mouse.focus(ctx, true)

			assert.is_true(ctx.s3.focus)
		end)

		it("should allow changing focus state", function()
			Mouse.focus(ctx, true)
			Mouse.focus(ctx, false)

			assert.is_false(ctx.s3.focus)
		end)
	end)
end)
