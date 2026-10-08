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
		it("should initialize two empty states", function()
			assert.same({}, ctx.s1)
			assert.same({}, ctx.s2)
		end)

		it("should create independent state tables", function()
			State.set(ctx, "button", true)

			assert.is_nil(ctx.s1.button)
			assert.is_true(ctx.s2.button)
		end)

		it("should expose get function", function()
			assert.equals(State.get, ctx.get)
		end)
	end)

	describe("set", function()
		it("should establish a signal in the current state", function()
			State.set(ctx, "button", true)

			assert.is_nil(ctx.s1.button)
			assert.is_true(ctx.s2.button)
		end)

		it("should replace the latest value of an established signal", function()
			State.set(ctx, "x", 10)
			State.set(ctx, "x", 20)

			assert.equals(20, ctx.s2.x)
		end)
	end)

	describe("step", function()
		it("should copy current values into the previous state", function()
			State.set(ctx, "button", true)
			State.set(ctx, "x", 10)
			State.step(ctx)
			assert.same({ button = true, x = 10 }, ctx.s1)

			State.set(ctx, "button", false)
			State.set(ctx, "x", 20)

			State.step(ctx)

			assert.same({ button = false, x = 20 }, ctx.s1)
			assert.same({ button = false, x = 20 }, ctx.s2)
		end)

		it("should keep the latest state unchanged", function()
			State.set(ctx, "button", true)
			State.set(ctx, "x", 20)

			State.step(ctx)

			assert.same({ button = true, x = 20 }, ctx.s2)
		end)
	end)

	describe("get", function()
		it("should return nil values for an unknown signal", function()
			local previous, current = State.get(ctx, "button")

			assert.is_nil(previous)
			assert.is_nil(current)
		end)

		it("should return the previous and current values", function()
			State.set(ctx, "button", true)

			local previous, current = ctx:get("button")
			assert.is_nil(previous)
			assert.is_true(current)

			State.step(ctx)
			State.set(ctx, "button", false)

			previous, current = ctx:get("button")
			assert.is_true(previous)
			assert.is_false(current)
		end)

		it("should return only the requested signal", function()
			State.set(ctx, "button", true)
			State.set(ctx, "x", 10)

			local previous, current = ctx:get("button")

			assert.is_nil(previous)
			assert.is_true(current)
		end)
	end)
end)
