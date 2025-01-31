# frozen_string_literal: true

require "sumi/version"
require "set"

module Sumi
	def self.inspect(object, indent: 0, tab_width: 2, max_width: 60, max_depth: 5, max_instance_variables: 10, original_object: nil)
		return "self" if object && object == original_object

		original_object ||= object

		case object
		when Hash
			return "{}" if object.empty?

			buffer = +"{\n"
			indent += 1
			object.each do |key, value|
				buffer << ("\t" * indent)
				case key
				when Symbol
					buffer << "#{key.name}: "
				else
					buffer << inspect(key, indent:, original_object:)
					buffer << " => "
				end
				buffer << inspect(value, indent:, original_object:)
				buffer << ",\n"
			end
			indent -= 1
			buffer << ("\t" * indent)
			buffer << "}"
		when Array
			new_lines = false
			length = 0
			items = object.map do |item|
				pretty_item = inspect(item, indent: indent + 1, original_object:)
				new_lines = true if pretty_item.include?("\n")
				length += pretty_item.bytesize
				pretty_item
			end

			if new_lines || length > max_width - (indent * tab_width)
				"[\n#{"\t" * (indent + 1)}#{items.join(",\n#{"\t" * (indent + 1)}")},\n#{"\t" * indent}]"
			else
				"[#{items.join(', ')}]"
			end
		when Set
			new_lines = false
			length = 0
			items = object.to_a.sort!.map do |item|
				pretty_item = inspect(item, indent: indent + 1, original_object:)
				new_lines = true if pretty_item.include?("\n")
				length += pretty_item.bytesize
				pretty_item
			end

			if new_lines || length > max_width - (indent * tab_width)
				"Set[\n#{"\t" * (indent + 1)}#{items.join(",\n#{"\t" * (indent + 1)}")},\n#{"\t" * indent}]"
			else
				"Set[#{items.join(', ')}]"
			end
		when Module
			object.name
		when Pathname
			%(Pathname("#{object.to_path}"))
		when Date, DateTime, Time
			%(#{object.class.name}("#{object}"))
		when Exception
			%(#{object.class.name}("#{object.message}"))
		when Symbol, String, Integer, Float, Regexp, Range, Rational, Complex, true, false, nil
			object.inspect
		when defined?(Data) && Data
			buffer = +""
			members = object.members.take(max_instance_variables) # TODO: either rename max_instance_variables to max_properties or define a max_members specifcally for data objects
			total_count = object.members.length
			items = members.map { |key| [key, object.__send__(key)] }

			inspect_object(object:, original_object:, buffer:, items:, total_count:, indent:, max_depth:, max_instance_variables:, separator: ": ")
		else
			buffer = +""
			instance_variables = object.instance_variables.take(max_instance_variables)
			total_count = object.instance_variables.length
			items = instance_variables.map { |name| [name, object.instance_variable_get(name)] }

			inspect_object(object:, original_object:, buffer:, items:, total_count:, indent:, max_depth:, max_instance_variables:, separator: " = ")
		end
	end

	def self.inspect_object(object:, original_object:, buffer:, items:, total_count:, indent:, max_depth:, max_instance_variables:, separator:)
		if total_count > 0 && indent < max_depth
			buffer << "#{object.class.name}(\n"
			indent += 1

			if indent < max_depth
				items.take(max_instance_variables).each do |key, value|
					buffer << ("\t" * indent)
					buffer << "#{key}#{separator}"

					buffer << inspect(value, indent:, original_object:)
					buffer << ",\n"
				end

				if total_count > max_instance_variables
					buffer << ("\t" * indent)
					buffer << "...\n"
				end
			else
				buffer << ("\t" * indent)
				buffer << "...\n"
			end

			indent -= 1
			buffer << ("\t" * indent)
			buffer << ")"
		elsif indent >= max_depth
			buffer << "#{object.class.name}(...)"
		else
			buffer << "#{object.class.name}()"
		end
	end
end
