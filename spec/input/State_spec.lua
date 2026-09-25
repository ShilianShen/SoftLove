package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local State = require("softlove.input.State")

describe("State", function()
	local ctx
	local signals

	before_each(function()
		ctx = {}
		signals = {
			button = false,
			x = 0,
		}
		State.init(ctx, signals)
	end)

	describe("init", function()
		it("should initialize three states from signals", function()
			assert.same(signals, ctx.s1)
			assert.same(signals, ctx.s2)
			assert.same(signals, ctx.s3)
		end)

		it("should create independent state tables", function()
			ctx.s3.button = true

			assert.is_false(ctx.s1.button)
			assert.is_false(ctx.s2.button)
			assert.is_true(ctx.s3.button)
		end)

		it("should expose visit function", function()
			assert.equals(State.visit, ctx.visit)
		end)
	end)

	describe("update", function()
		it("should shift newer values into previous states", function()
			ctx.s2.button = true
			ctx.s2.x = 10
			ctx.s3.button = false
			ctx.s3.x = 20

			State.update(ctx)

			assert.same({ button = true, x = 10 }, ctx.s1)
			assert.same({ button = false, x = 20 }, ctx.s2)
		end)

		it("should keep the latest state unchanged", function()
			ctx.s3.button = true
			ctx.s3.x = 20

			State.update(ctx)

			assert.same({ button = true, x = 20 }, ctx.s3)
		end)
	end)

	describe("isDynamic", function()
		it("should return false when all states are equal", function()
			assert.is_false(State.isDynamic(ctx))
		end)

		it("should return true when the previous states differ", function()
			ctx.s2.button = true

			assert.is_true(State.isDynamic(ctx))
		end)

		it("should return true when the latest state differs", function()
			ctx.s3.x = 10

			assert.is_true(State.isDynamic(ctx))
		end)

		it("should return false after equal values are propagated", function()
			ctx.s3.button = true
			State.update(ctx)
			State.update(ctx)

			assert.is_false(State.isDynamic(ctx))
		end)
	end)

	describe("visit", function()
		it("should return read-only views of the first two states", function()
			local s1, s2 = State.visit(ctx)

			assert.is_false(s1.button)
			assert.equals(0, s1.x)
			assert.is_false(s2.button)
			assert.equals(0, s2.x)
		end)

		it("should keep views in sync with state updates", function()
			local s1, s2 = State.visit(ctx)
			ctx.s3.x = 10

			State.update(ctx)

			assert.equals(0, s1.x)
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

			assert.is_false(ctx.s1.button)
			assert.equals(0, ctx.s2.x)
		end)

		it("should protect view metatables", function()
			local s1, s2 = State.visit(ctx)

			assert.is_false(getmetatable(s1))
			assert.is_false(getmetatable(s2))
		end)
	end)
end)
