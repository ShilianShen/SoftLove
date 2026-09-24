package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local Window = require("softlove.system.Window")

describe("Window", function()
	local ctx

	before_each(function()
		ctx = {}
		Window.init(ctx)
	end)

	describe("init", function()
		it("should initialize window size to zero", function()
			assert.equals(0, ctx.w)
			assert.equals(0, ctx.h)
		end)

		it("should set visible to false", function()
			assert.is_false(ctx.visible)
		end)

		it("should set focus to false", function()
			assert.is_false(ctx.focus)
		end)
	end)

	describe("focus", function()
		it("should update focus state", function()
			Window.focus(ctx, true)

			assert.is_true(ctx.focus)
		end)

		it("should allow changing focus state", function()
			Window.focus(ctx, true)
			Window.focus(ctx, false)

			assert.is_false(ctx.focus)
		end)
	end)

	describe("visible", function()
		it("should update visible state", function()
			Window.visible(ctx, true)

			assert.is_true(ctx.visible)
		end)

		it("should allow changing visible state", function()
			Window.visible(ctx, true)
			Window.visible(ctx, false)

			assert.is_false(ctx.visible)
		end)
	end)

	describe("resize", function()
		it("should update window size", function()
			Window.resize(ctx, 1280, 720)

			assert.equals(1280, ctx.w)
			assert.equals(720, ctx.h)
		end)

		it("should allow changing window size", function()
			Window.resize(ctx, 1280, 720)
			Window.resize(ctx, 1920, 1080)

			assert.equals(1920, ctx.w)
			assert.equals(1080, ctx.h)
		end)
	end)
end)
