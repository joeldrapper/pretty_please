# frozen_string_literal: true

require "pretty_please/version"
require "dispersion"

module PrettyPlease
	autoload :Inspect, "pretty_please/inspect"

	def self.print(object)
		puts Dispersion.ansi(inspect(object))
	end

	def self.inspect(...)
		Inspect::(...)
	end
end
