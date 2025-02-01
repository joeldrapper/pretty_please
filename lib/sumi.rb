# frozen_string_literal: true

require "sumi/version"
require "dispersion"

module Sumi
	autoload :Inspect, "sumi/inspect"

	def self.print(object)
		puts Dispersion.ansi(inspect(object))
	end

	def self.inspect(...)
		Inspect::(...)
	end
end
