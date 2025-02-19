# frozen_string_literal: true

require "pretty_please/version"
require "dispersion"

module PrettyPlease
	autoload :Prettifier, "pretty_please/prettifier"

	def self.print(...)
		puts Dispersion.ansi(prettify(...))
	end

	def self.inspect(...)
		warn "PrettyPlease.inspect is deprecated. Use PrettyPlease.prettify instead."
		prettify(...)
	end

	def self.prettify(...)
		Prettifier::(...)
	end
end
