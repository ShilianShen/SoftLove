package.path = "src/?.lua;" .. "src/?/init.lua;" .. package.path
local assert = require("luassert")
local locales = require("softlove.locales")

describe("locales", function()
	local ctx

	before_each(function()
		ctx = {}
		locales.init(ctx)
	end)

	describe("init", function()
		it("should initialize translater", function()
			assert.is_table(ctx.translater)
			assert.same({}, ctx.translater)
		end)

		it("should set current to false", function()
			assert.is_false(ctx.current)
		end)

		it("should expose translate function", function()
			assert.is_function(ctx.translate)
			assert.equals(locales.getter.translate, ctx.translate)
		end)
	end)

	describe("setCurrent", function()
		it("should set current locale", function()
			locales.setter.setCurrent(ctx, "zh_CN")

			assert.equals("zh_CN", ctx.current)
		end)

		it("should allow changing current locale", function()
			locales.setter.setCurrent(ctx, "zh_CN")
			locales.setter.setCurrent(ctx, "en_US")

			assert.equals("en_US", ctx.current)
		end)
	end)

	describe("translate", function()
		it("should return key when current locale is not set", function()
			local result = ctx:translate("hello")

			assert.equals("hello", result)
		end)

		it("should return translated value for current locale", function()
			ctx.translater.zh_CN = {
				hello = "你好",
			}

			locales.setter.setCurrent(ctx, "zh_CN")

			assert.equals("你好", ctx:translate("hello"))
		end)

		it("should return nil when translation key does not exist", function()
			ctx.translater.zh_CN = {
				hello = "你好",
			}

			locales.setter.setCurrent(ctx, "zh_CN")

			assert.is_nil(ctx:translate("not_exists"))
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

		it("should load locale file and add it to translater", function()
			locales.setter.add(ctx, "zh_CN", "test_locale_zh")

			assert.same({
				hello = "你好",
				world = "世界",
			}, ctx.translater.zh_CN)
		end)

		it("should allow translating after locale is added", function()
			locales.setter.add(ctx, "zh_CN", "test_locale_zh")
			locales.setter.setCurrent(ctx, "zh_CN")

			assert.equals("你好", ctx:translate("hello"))
			assert.equals("世界", ctx:translate("world"))
		end)
	end)

	describe("del", function()
		before_each(function()
			ctx.translater.zh_CN = {
				hello = "你好",
			}

			ctx.translater.en_US = {
				hello = "Hello",
			}
		end)

		it("should delete specified locale", function()
			locales.setter.del(ctx, "zh_CN")

			assert.is_nil(ctx.translater.zh_CN)
			assert.is_not_nil(ctx.translater.en_US)
		end)

		it("should clear current when deleting current locale", function()
			locales.setter.setCurrent(ctx, "zh_CN")

			locales.setter.del(ctx, "zh_CN")

			assert.is_false(ctx.current)
		end)

		it("should keep current when deleting another locale", function()
			locales.setter.setCurrent(ctx, "en_US")

			locales.setter.del(ctx, "zh_CN")

			assert.equals("en_US", ctx.current)
		end)

		it("should not fail when deleting nonexistent locale", function()
			assert.has_no.errors(function()
				locales.setter.del(ctx, "not_exists")
			end)

			assert.is_nil(ctx.translater.not_exists)
		end)
	end)
end)
