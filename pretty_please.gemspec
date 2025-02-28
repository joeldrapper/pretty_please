# frozen_string_literal: true

require_relative "lib/pretty_please/version"

Gem::Specification.new do |spec|
	spec.name = "pretty_please"
	spec.version = PrettyPlease::VERSION
	spec.authors = ["Joel Drapper", "Marco Roth"]
	spec.email = ["joel@drapper.me", "marco.roth@intergga.ch"]

	spec.summary = "Print Ruby objects as Ruby"
	spec.description = spec.summary
	spec.homepage = "https://github.com/joeldrapper/pretty_please"
	spec.license = "MIT"
	spec.required_ruby_version = ">= 3.1"

	spec.metadata["homepage_uri"] = spec.homepage
	spec.metadata["source_code_uri"] = "https://github.com/joeldrapper/pretty_please"
	spec.metadata["funding_uri"] = "https://github.com/sponsors/joeldrapper"

	spec.files = Dir[
		"README.md",
		"LICENSE.txt",
		"lib/**/*.rb"
	]

	spec.require_paths = ["lib"]

	spec.metadata["rubygems_mfa_required"] = "true"

	spec.add_dependency "dispersion", "~> 0.2"
end
