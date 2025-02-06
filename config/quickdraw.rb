# frozen_string_literal: true

if ENV["COVERAGE"] == "true"
	require "simplecov"

	SimpleCov.start do
		command_name "quickdraw"
		enable_coverage_for_eval
		enable_for_subprocesses true
		enable_coverage :branch
	end
end

Bundler.require :test

require "pretty_please"

class Example
	def initialize
		@foo = 1
		@bar = [2, 3, 4]
	end
end

module ActiveRecord
	if defined?(ActiveRecord::Base)
		raise "ActiveRecord::Base is already defined, remove the 'ActiveRecord::Base' stub in the 'config/quickdraw.rb' file."
	end

	class Base
	end
end

class TestModel < ActiveRecord::Base
	attr_reader :attributes

	def initialize
		@attributes = {
			"id" => 1,
			"name" => "Test Model",
			"created_at" => Time.new("2025-02-06 01:02:03 UTC"),
			"updated_at" => Time.new("2025-02-06 04:05:06 UTC"),
			"date" => Date.parse("2025-02-06"),
			"tags" => ["tag_1", "tag_2", "tag_3"],
			"attribute_1" => "value_1",
			"attribute_2" => "value_2",
			"attribute_3" => "value_3",
			"attribute_4" => "value_4",
			"attribute_5" => "value_5",
			"attribute_6" => "value_6",
			"attribute_7" => "value_7",
			"attribute_8" => "value_8",
			"attribute_9" => "value_9",
		}
	end
end
