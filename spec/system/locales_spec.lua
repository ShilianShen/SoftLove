package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local locales = require("softlove.system.locales")

describe("locales", function()
	local ctx

	before_each(function()
		ctx = {}
		locales.init(ctx)
	end)

	describe("init", function()
		it("should initialize translator", function()
			assert.is_table(ctx.translator)
			assert.same({}, ctx.translator)
		end)

		it("should set current to false", function()
			assert.is_false(ctx.current)
		end)

		it("should not expose translate function", function()
			assert.is_nil(ctx.translate)
		end)
	end)

	describe("setCurrent", function()
		it("should set current locale", function()
			locales.setCurrent(ctx, "zh_CN")

			assert.equals("zh_CN", ctx.current)
		end)

		it("should allow changing current locale", function()
			locales.setCurrent(ctx, "zh_CN")
			locales.setCurrent(ctx, "en_US")

			assert.equals("en_US", ctx.current)
		end)
	end)

	describe("translate", function()
		it("should return key when current locale is not set", function()
			local result = locales.translate(ctx, "hello")

			assert.equals("hello", result)
		end)

		it("should return translated value for current locale", function()
			ctx.translator.zh_CN = {
				hello = "你好",
			}

			locales.setCurrent(ctx, "zh_CN")

			assert.equals("你好", locales.translate(ctx, "hello"))
		end)

		it("should return nil when translation key does not exist", function()
			ctx.translator.zh_CN = {
				hello = "你好",
			}

			locales.setCurrent(ctx, "zh_CN")

			assert.is_nil(locales.translate(ctx, "not_exists"))
		end)
	end)

	describe("add", function()
		before_each(function()
			package.loaded["test_locale_zh"] = nil

			package.preload["test_locale_zh"] = function()
				return {
					hello = "你好",
					world = "世界",
				}
			end
		end)

		after_each(function()
			package.loaded["test_locale_zh"] = nil
			package.preload["test_locale_zh"] = nil
		end)

		it("should load locale file and add it to translator", function()
			locales.add(ctx, "zh_CN", "test_locale_zh")

			assert.same({
				hello = "你好",
				world = "世界",
			}, ctx.translator.zh_CN)
		end)

		it("should allow translating after locale is added", function()
			locales.add(ctx, "zh_CN", "test_locale_zh")
			locales.setCurrent(ctx, "zh_CN")

			assert.equals("你好", locales.translate(ctx, "hello"))
			assert.equals("世界", locales.translate(ctx, "world"))
		end)
	end)

	describe("del", function()
		before_each(function()
			ctx.translator.zh_CN = {
				hello = "你好",
			}

			ctx.translator.en_US = {
				hello = "Hello",
			}
		end)

		it("should delete specified locale", function()
			locales.del(ctx, "zh_CN")

			assert.is_nil(ctx.translator.zh_CN)
			assert.is_not_nil(ctx.translator.en_US)
		end)

		it("should clear current when deleting current locale", function()
			locales.setCurrent(ctx, "zh_CN")

			locales.del(ctx, "zh_CN")

			assert.is_false(ctx.current)
		end)

		it("should keep current when deleting another locale", function()
			locales.setCurrent(ctx, "en_US")

			locales.del(ctx, "zh_CN")

			assert.equals("en_US", ctx.current)
		end)

		it("should not fail when deleting nonexistent locale", function()
			assert.has_no.errors(function()
				locales.del(ctx, "not_exists")
			end)

			assert.is_nil(ctx.translator.not_exists)
		end)
	end)
end)
