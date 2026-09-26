package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local State = require("softlove.input.State")

describe("State", function()
	local ctx

	before_each(function()
		ctx = {}
		State.init(ctx)
	end)

	describe("init", function()
		it("should initialize three empty states", function()
			assert.same({}, ctx.s1)
			assert.same({}, ctx.s2)
			assert.same({}, ctx.s3)
		end)

		it("should create independent state tables", function()
			State.set(ctx, "button", true)

			assert.is_nil(ctx.s1.button)
			assert.is_nil(ctx.s2.button)
			assert.is_true(ctx.s3.button)
		end)

		it("should expose visit function", function()
			assert.equals(State.visit, ctx.visit)
		end)
	end)

	describe("set", function()
		it("should establish a signal dynamically in the latest state", function()
			State.set(ctx, "button", true)

			assert.is_nil(ctx.s1.button)
			assert.is_nil(ctx.s2.button)
			assert.is_true(ctx.s3.button)
		end)

		it("should replace the latest value of an established signal", function()
			State.set(ctx, "x", 10)
			State.set(ctx, "x", 20)

			assert.equals(20, ctx.s3.x)
		end)
	end)

	describe("update", function()
		it("should shift newer values into previous states", function()
			State.set(ctx, "button", true)
			State.set(ctx, "x", 10)
			State.update(ctx)
			State.set(ctx, "button", false)
			State.set(ctx, "x", 20)

			State.update(ctx)

			assert.same({ button = true, x = 10 }, ctx.s1)
			assert.same({ button = false, x = 20 }, ctx.s2)
		end)

		it("should keep the latest state unchanged", function()
			State.set(ctx, "button", true)
			State.set(ctx, "x", 20)

			State.update(ctx)

			assert.same({ button = true, x = 20 }, ctx.s3)
		end)
	end)

	describe("isDynamic", function()
		it("should return false when no signals have been established", function()
			assert.is_false(State.isDynamic(ctx))
		end)

		it("should return true while a new signal is being propagated", function()
			State.set(ctx, "button", true)
			State.update(ctx)

			assert.is_true(State.isDynamic(ctx))
		end)

		it("should return true when the latest state differs", function()
			State.set(ctx, "x", 10)

			assert.is_true(State.isDynamic(ctx))
		end)

		it("should return false after equal values are propagated", function()
			State.set(ctx, "button", true)
			State.update(ctx)
			State.update(ctx)

			assert.is_false(State.isDynamic(ctx))
		end)
	end)

	describe("visit", function()
		it("should return read-only views of the first two states", function()
			local s1, s2 = State.visit(ctx)

			assert.is_nil(s1.button)
			assert.is_nil(s1.x)
			assert.is_nil(s2.button)
			assert.is_nil(s2.x)
		end)

		it("should keep views in sync with state updates", function()
			local s1, s2 = State.visit(ctx)
			State.set(ctx, "x", 10)

			State.update(ctx)

			assert.is_nil(s1.x)
			assert.equals(10, s2.x)
		end)

		it("should prevent modifying views", function()
			local s1, s2 = State.visit(ctx)

			assert.has_error(function()
				s1.button = true
			end)
			assert.has_error(function()
				s2.x = 10
			end)

			assert.is_nil(ctx.s1.button)
			assert.is_nil(ctx.s2.x)
		end)

		it("should protect view metatables", function()
			local s1, s2 = State.visit(ctx)

			assert.is_false(getmetatable(s1))
			assert.is_false(getmetatable(s2))
		end)
	end)
end)
