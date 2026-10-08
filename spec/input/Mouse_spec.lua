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
		it("should initialize two empty mouse states", function()
			assert.same({}, ctx.s1)
			assert.same({}, ctx.s2)
		end)

		it("should create independent mouse states", function()
			Mouse.pressed(ctx, 10, 20, 1, false, 1)
			Mouse.moved(ctx, 10, 20, 10, 20, false)

			assert.is_nil(ctx.s1[1])
			assert.is_true(ctx.s2[1])
			assert.is_nil(ctx.s1.x)
			assert.equals(10, ctx.s2.x)
		end)

		it("should expose get function", function()
			assert.is_function(ctx.get)
		end)
	end)

	describe("get", function()
		it("should return previous and current button states", function()
			Mouse.pressed(ctx, 10, 20, 2, false, 1)

			local previous, current = ctx:get(2)

			assert.is_nil(previous)
			assert.is_true(current)

			Mouse.step(ctx)
			Mouse.released(ctx, 10, 20, 2, false, 1)
			previous, current = ctx:get(2)

			assert.is_true(previous)
			assert.is_false(current)
		end)

		it("should return mouse position and focus values", function()
			Mouse.moved(ctx, 100, 200, 10, 20, false)
			Mouse.focus(ctx, true)

			local _, x = ctx:get("x")
			local _, y = ctx:get("y")
			local _, focus = ctx:get("focus")

			assert.equals(100, x)
			assert.equals(200, y)
			assert.is_true(focus)
		end)
	end)

	describe("pressed", function()
		it("should mark the pressed button as down", function()
			Mouse.pressed(ctx, 10, 20, 2, false, 1)

			assert.is_true(ctx.s2[2])
		end)

		it("should not change other buttons", function()
			Mouse.pressed(ctx, 10, 20, 2, false, 1)

			assert.is_nil(ctx.s2[1])
			assert.is_nil(ctx.s2[3])
		end)
	end)

	describe("released", function()
		it("should mark the released button as up", function()
			Mouse.pressed(ctx, 10, 20, 2, false, 1)

			Mouse.released(ctx, 10, 20, 2, false, 1)

			assert.is_false(ctx.s2[2])
		end)

		it("should not change other buttons", function()
			ctx.s2[1] = true
			ctx.s2[2] = true

			Mouse.released(ctx, 10, 20, 2, false, 1)

			assert.is_true(ctx.s2[1])
			assert.is_false(ctx.s2[2])
		end)
	end)

	describe("moved", function()
		it("should update the latest mouse position", function()
			Mouse.moved(ctx, 100, 200, 10, 20, false)

			assert.equals(100, ctx.s2.x)
			assert.equals(200, ctx.s2.y)
		end)

		it("should allow replacing the latest mouse position", function()
			Mouse.moved(ctx, 100, 200, 10, 20, false)
			Mouse.moved(ctx, 300, 400, 200, 200, false)

			assert.equals(300, ctx.s2.x)
			assert.equals(400, ctx.s2.y)
		end)
	end)

	describe("focus", function()
		it("should update focus state", function()
			Mouse.focus(ctx, true)

			assert.is_true(ctx.s2.focus)
		end)

		it("should allow changing focus state", function()
			Mouse.focus(ctx, true)
			Mouse.focus(ctx, false)

			assert.is_false(ctx.s2.focus)
		end)
	end)
end)
