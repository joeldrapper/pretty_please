# frozen_string_literal: true

class Sumi::Inspect
	def self.call(object, ...)
		new(...).call(object)
	end

	def initialize(indent: 0, tab_width: 2, max_width: 30, max_items: 10, max_depth: 5)
		@indent = indent
		@tab_width = tab_width
		@max_width = max_width
		@max_items = max_items
		@max_depth = max_depth
		@indent_bytes = " " * @tab_width

		@buffer = +""
		@lines = 0 # note, this is not reset within a capture
		@stack = []
	end

	def call(object)
		inspect(object)
		@buffer
	end

	def map(object, around_inline: nil)
		return unless object.any?

		length = 0
		original_lines = @lines
		exceeds_max_items = object.length > @max_items

		items = object.take(@max_items).map do |item|
			pretty_item = yield(item)
			length += pretty_item.bytesize
			pretty_item
		end

		if (@lines > original_lines) || (length > @max_width - (@indent * @tab_width))
			indent do
				items.each do |item|
					newline
					push item
					push ","
				end

				if exceeds_max_items
					newline
					push "..."
				end
			end

			newline
		else
			push around_inline
			push items.join(", ")
			push ", ..." if exceeds_max_items
			push around_inline
		end
	end

	def indent
		@indent += 1
		yield
		@indent -= 1
	end

	def newline
		@lines += 1
		push "\n"
		push @indent_bytes * @indent
	end

	def push(string)
		return unless string
		@buffer << string
	end

	def capture
		original_buffer = @buffer
		new_buffer = +""
		@buffer = new_buffer
		yield
		@buffer = original_buffer
		new_buffer
	end

	private

	def inspect(object)
		if (last = @stack.last) && last == object
			push "self"
			return
		else
			@stack.push(object)
		end

		case object
		when Symbol, String, Integer, Float, Regexp, Range, Rational, Complex, TrueClass, FalseClass, NilClass
			push object.inspect
		when Module
			push object.name
		when Pathname, File
			push %(#{object.class.name}("#{object.to_path}"))
		when MatchData, (defined?(Date) && Date), (defined?(DateTime) && DateTime), (defined?(Time) && Time), (defined?(URI) && URI)
			push %(#{object.class.name}("#{object}"))
		when Array
			push "["
			map(object) { |it| capture { inspect(it) } }
			push "]"
		when Exception
			push %(#{object.class.name}("#{object.message}"))
		when Hash
			push "{"
			map(object, around_inline: " ") do |key, value|
				case key
				when Symbol
					"#{key.name}: #{capture { inspect(value) }}"
				else
					key = capture { inspect(key) }
					value = capture { inspect(value) }
					"#{key} => #{value}"
				end
			end
			push "}"
		when Struct, defined?(Data) && Data
			push object.class.name
			push "("
			items = object.members.map { |key| [key, object.__send__(key)] }
			map(items) { |key, value| "#{key}: #{capture { inspect(value) }}" }
			push ")"
		when defined?(Set) && Set
			push "Set["
			map(object.to_a.sort) { |it| capture { inspect(it) } }
			push "]"
		else
			push "#{object.class.name}("
			map(object.instance_variables) do |name|
				"#{name} = #{capture { inspect(object.instance_variable_get(name)) }}"
			end
			push ")"
		end

		@stack.pop
	end
end
