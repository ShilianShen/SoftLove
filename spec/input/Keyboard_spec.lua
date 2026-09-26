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
			assert.same({}, ctx.keys.s3)
			assert.same({}, ctx.scancodes.s1)
			assert.same({}, ctx.scancodes.s2)
			assert.same({}, ctx.scancodes.s3)
		end)

		it("should keep key and scancode states independent", function()
			ctx.keys.s3.space = true

			assert.is_true(ctx.keys.s3.space)
			assert.is_nil(ctx.scancodes.s3.space)
		end)
	end)

	describe("update", function()
		it("should update both key and scancode states", function()
			Keyboard.pressed(ctx, "space", "space_scancode", false)

			Keyboard.update(ctx)

			assert.is_true(ctx.keys.s2.space)
			assert.is_true(ctx.scancodes.s2.space_scancode)
		end)
	end)

	describe("isDynamic", function()
		it("should return false when both states are stable", function()
			assert.is_false(Keyboard.isDynamic(ctx))
		end)

		it("should return true when the keyboard state changes", function()
			Keyboard.pressed(ctx, "space", "space_scancode", false)

			assert.is_true(Keyboard.isDynamic(ctx))
		end)

		it("should return false after values have propagated", function()
			Keyboard.pressed(ctx, "space", "space_scancode", false)
			Keyboard.update(ctx)
			Keyboard.update(ctx)

			assert.is_false(Keyboard.isDynamic(ctx))
		end)
	end)

	describe("visit", function()
		it("should return key states when visiting keys", function()
			Keyboard.pressed(ctx, "space", "space_scancode", false)
			Keyboard.update(ctx)

			local s1, s2 = Keyboard.visit(ctx, "keys")

			assert.is_nil(s1.space)
			assert.is_true(s2.space)
			assert.is_nil(s2.space_scancode)
		end)

		it("should return scancode states when visiting scancodes", function()
			Keyboard.pressed(ctx, "space", "space_scancode", false)
			Keyboard.update(ctx)

			local s1, s2 = Keyboard.visit(ctx, "scancodes")

			assert.is_nil(s1.space_scancode)
			assert.is_true(s2.space_scancode)
			assert.is_nil(s2.space)
		end)
	end)

	describe("pressed", function()
		it("should set the latest key and scancode states to true", function()
			Keyboard.pressed(ctx, "space", "space_scancode", false)

			assert.is_true(ctx.keys.s3.space)
			assert.is_true(ctx.scancodes.s3.space_scancode)
		end)
	end)

	describe("released", function()
		it("should set the latest key and scancode states to false", function()
			Keyboard.pressed(ctx, "space", "space_scancode", false)

			Keyboard.released(ctx, "space", "space_scancode")

			assert.is_false(ctx.keys.s3.space)
			assert.is_false(ctx.scancodes.s3.space_scancode)
		end)
	end)
end)
