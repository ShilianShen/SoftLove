package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local Keyboard = require("softlove.input.Keyboard")

describe("Keyboard", function()
	local ctx

	before_each(function()
		ctx = {}
		Keyboard.init(ctx)
	end)

	describe("init", function()
		it("should initialize empty key and scancode states", function()
			assert.same({}, ctx.keys.s1)
			assert.same({}, ctx.keys.s2)
			assert.same({}, ctx.scancodes.s1)
			assert.same({}, ctx.scancodes.s2)
		end)

		it("should keep key and scancode states independent", function()
			ctx.keys.s2.space = true

			assert.is_true(ctx.keys.s2.space)
			assert.is_nil(ctx.scancodes.s2.space)
		end)

		it("should expose key and scancode getters", function()
			assert.equals(Keyboard.getKey, ctx.getKey)
			assert.equals(Keyboard.getScancode, ctx.getScancode)
		end)
	end)

	describe("step", function()
		it("should update both key and scancode states", function()
			Keyboard.pressed(ctx, "space", "a", false)

			Keyboard.step(ctx)

			assert.is_true(ctx.keys.s1.space)
			assert.is_true(ctx.keys.s2.space)
			assert.is_true(ctx.scancodes.s1.a)
			assert.is_true(ctx.scancodes.s2.a)
		end)
	end)

	describe("get", function()
		it("should return key states", function()
			Keyboard.pressed(ctx, "space", "a", false)

			local previous, current = ctx:getKey("space")

			assert.is_nil(previous)
			assert.is_true(current)
			assert.is_nil(ctx:getKey("a"))
		end)

		it("should return scancode states", function()
			Keyboard.pressed(ctx, "space", "a", false)

			local previous, current = ctx:getScancode("a")

			assert.is_nil(previous)
			assert.is_true(current)
			assert.is_nil(ctx:getScancode("space"))
		end)

		it("should return previous and current key states", function()
			Keyboard.pressed(ctx, "space", "a", false)
			Keyboard.step(ctx)
			Keyboard.released(ctx, "space", "a")

			local previous, current = ctx:getKey("space")

			assert.is_true(previous)
			assert.is_false(current)
		end)
	end)

	describe("pressed", function()
		it("should set the latest key and scancode states to true", function()
			Keyboard.pressed(ctx, "space", "a", false)

			assert.is_true(ctx.keys.s2.space)
			assert.is_true(ctx.scancodes.s2.a)
		end)
	end)

	describe("released", function()
		it("should set the latest key and scancode states to false", function()
			Keyboard.pressed(ctx, "space", "a", false)

			Keyboard.released(ctx, "space", "a")

			assert.is_false(ctx.keys.s2.space)
			assert.is_false(ctx.scancodes.s2.a)
		end)
	end)
end)
