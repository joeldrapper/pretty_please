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
