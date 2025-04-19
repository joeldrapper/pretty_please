# frozen_string_literal: true

require "set"
require "uri"
require "date"

def prettify(...)
	PrettyPlease.prettify(...)
end

test "objects" do
	assert_equal_ruby prettify(Example.new), <<~RUBY.chomp
		Example(
		  @foo = 1,
		  @bar = [2, 3, 4],
		)
	RUBY
end

test "object with no properties" do
	assert_equal_ruby prettify(Object.new), %(Object())
end

test "nested object and inlining" do
	object = { hello: "123", world: { another: { layer: [1, 2, 3, { id: 1, object: { enabled: true } }] } } }

	assert_equal_ruby prettify(object), <<~RUBY.chomp
		{
		  hello: "123",
		  world: {
		    another: {
		      layer: [1, 2, 3, {...}],
		    },
		  },
		}
	RUBY
end

test "struct" do
	customer = Struct.new(:name, :address) do
		def self.name
			"Customer"
		end
	end

	assert_equal_ruby prettify(customer.new("Dave", "123 Main")), <<~RUBY.chomp
    Customer(
      name: "Dave",
      address: "123 Main",
    )
	RUBY
end

if (Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3"))
	test "empty struct" do
		empty = Struct.new do
			def self.name
				"Empty"
			end
		end

		assert_equal_ruby prettify(empty.new), <<~RUBY.chomp
			Empty()
		RUBY
	end
end

if (Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.2"))
	test "data objects" do
		measure = Data.define(:amount, :unit) do
			def self.name
				"Measure"
			end
		end

		assert_equal_ruby prettify(measure.new(100, "km")), <<~RUBY.chomp
			Measure(amount: 100, unit: "km")
		RUBY
	end

	test "data objects with no properties" do
		empty = Data.define do
			def self.name
				"Empty"
			end
		end

		assert_equal_ruby prettify(empty.new), %(Empty())
	end
end

test "empty set" do
	assert_equal_ruby prettify(Set.new), "Set[]"
end

test "empty array" do
	assert_equal_ruby prettify([]), "[]"
end

test "empty object" do
	assert_equal_ruby prettify({}), "{}"
end

test "empty string" do
	assert_equal_ruby prettify(""), %("")
end

test "empty symbol" do
	assert_equal_ruby prettify(:""), %(:"")
end

test "time" do
	assert_equal_ruby prettify(Time.at(1738319106).utc), %(Time("2025-01-31 10:25:06 UTC"))
end

test "integer" do
	assert_equal_ruby prettify(-1), %(-1)
	assert_equal_ruby prettify(0), %(0)
	assert_equal_ruby prettify(3), %(3)
end

test "float" do
	assert_equal_ruby prettify(3.1415), %(3.1415)
end

test "regexp" do
	assert_equal_ruby prettify(/\d{2}/), %(/\\d{2}/)
end

test "range" do
	assert_equal_ruby prettify(1..10), %(1..10)
	assert_equal_ruby prettify(1...10), %(1...10)
end

test "rational" do
	assert_equal_ruby prettify(Rational(1)), %((1/1))
	assert_equal_ruby prettify(Rational(2, 3)), %((2/3))
	assert_equal_ruby prettify(Rational(4, -6)), %((-2/3))
	assert_equal_ruby prettify(3.to_r), %((3/1))
	assert_equal_ruby prettify(2/3r), %((2/3))
end

test "complex" do
	assert_equal_ruby prettify(2 + 1i), %((2+1i))
	assert_equal_ruby prettify(Complex(1)), %((1+0i))
	assert_equal_ruby prettify(Complex(2, 3)), %((2+3i))
	assert_equal_ruby prettify(Complex.polar(2, 3)), %((-1.9799849932008908+0.2822400161197344i))
	assert_equal_ruby prettify(3.to_c), %((3+0i))
end

test "true" do
	assert_equal_ruby prettify(true), %(true)
end

test "false" do
	assert_equal_ruby prettify(false), %(false)
end

test "nil" do
	assert_equal_ruby prettify(nil), %(nil)
end

test "date" do
	assert_equal_ruby prettify(Date.parse("2015-01-31")), %(Date("2015-01-31"))
end

test "uri" do
	assert_equal_ruby prettify(URI.parse("https://example.com")), %(URI::HTTPS("https://example.com"))
end

test "date time" do
	assert_equal_ruby prettify(DateTime.parse("2025-01-31 11:17:18 +0100")), %(DateTime("2025-01-31T11:17:18+01:00"))
end

test "sets are not sorted" do
	object = Set[2, 3, 1]

	assert_equal_ruby prettify(object), <<~RUBY.chomp
		Set[2, 3, 1]
	RUBY
end

test "nested hashes" do
	object = {
		foo: {
			bar: {
				baz: 1,
			},
		},
	}

	assert_equal_ruby prettify(object), <<~RUBY.chomp
	  {
	    foo: {
	      bar: { baz: 1 },
	    },
	  }
	RUBY
end

test "nested arrays" do
	object = [[1, 2], [3, 4]]

	assert_equal_ruby prettify(object), <<~RUBY.chomp
		[
		  [1, 2],
		  [3, 4],
		]
	RUBY
end

test "long arrays" do
	object = [
		"One",
		"Two",
		"Three",
		"Four",
		"Five",
		"Six",
		"Seven",
		"Eight",
		"Nine",
		"Ten",
		"Eleven",
	]

	assert_equal prettify(object), <<~RUBY.chomp
		[
		  "One",
		  "Two",
		  "Three",
		  "Four",
		  "Five",
		  "Six",
		  "Seven",
		  "Eight",
		  "Nine",
		  "Ten",
		  ...
		]
	RUBY
end

test "array of nils" do
	assert_equal_ruby prettify([nil, nil]), <<~RUBY.chomp
		[nil, nil]
	RUBY
end

test "module and class" do
	assert_equal_ruby prettify([Difftastic, Integer]), <<~RUBY.chomp
		[Difftastic, Integer]
	RUBY
end

test "pathname" do
	assert_equal_ruby prettify(Pathname.new("")), <<~RUBY.chomp
		Pathname("")
	RUBY

	assert_equal_ruby prettify(Pathname.new("/")), <<~RUBY.chomp
		Pathname("/")
	RUBY

	assert_equal_ruby prettify(Pathname.new("/path/to/somewhere.txt")), <<~RUBY.chomp
		Pathname("/path/to/somewhere.txt")
	RUBY
end

test "simple self referencing" do
	object = []
	object << object

	assert_equal_ruby prettify(object), <<~RUBY.chomp
		[self]
	RUBY
end

test "self-referencing" do
	array = [1, 2, 3]

	object = {
		id: 1,
		array:,
	}

	sibling = {
		id: 2,
		array: array.reverse,
		previous_sibling: object,
	}

	parent = {
		object:,
		self_twice: [object, object],
	}

	object[:parent] = parent
	object[:next_sibling] = sibling

	parent[:children] = [
		object,
		sibling,
	]

	assert_equal_ruby prettify(object, max_depth: 10), <<~RUBY.chomp
		{
		  id: 1,
		  array: [1, 2, 3],
		  parent: {
		    object: self,
		    self_twice: [self, self],
		    children: [
		      self,
		      {
		        id: 2,
		        array: [3, 2, 1],
		        previous_sibling: self,
		      },
		    ],
		  },
		  next_sibling: {
		    id: 2,
		    array: [3, 2, 1],
		    previous_sibling: self,
		  },
		}
	RUBY
end

test "max_instance_variables" do
	object = Object.new

	1.upto(30) do |i|
		object.instance_variable_set(:"@variable_#{i}", i)
	end

	assert_equal_ruby prettify(object), <<~RUBY.chomp
		Object(
		  @variable_1 = 1,
		  @variable_2 = 2,
		  @variable_3 = 3,
		  @variable_4 = 4,
		  @variable_5 = 5,
		  @variable_6 = 6,
		  @variable_7 = 7,
		  @variable_8 = 8,
		  @variable_9 = 9,
		  @variable_10 = 10,
		  ...
		)
	RUBY
end

test "max_depth" do
	max_depth = Class.new do
		def self.name
			"MaxDepth"
		end

		def initialize(value)
			@value = value
		end
	end

	level4 = max_depth.new(["level4"])
	level3 = max_depth.new(["level3", level4])
	level2 = max_depth.new(["level2", level3])
	level1 = max_depth.new(["level1", level2])
	object = max_depth.new(["object", level1])

	assert_equal_ruby prettify(object), <<~RUBY.chomp
		MaxDepth(
		  @value = [
		    "object",
		    MaxDepth(
		      @value = ["level1", MaxDepth(...)],
		    ),
		  ],
		)
	RUBY
end

test "exception" do
	exception = ArgumentError.new("message")

	assert_equal_ruby prettify(exception), <<~RUBY.chomp
		ArgumentError("message")
	RUBY
end

test "file" do
	file = Tempfile.create

	assert_equal_ruby prettify(file), <<~RUBY.chomp
		File("#{file.to_path}")
	RUBY
end

test "match data" do
	match_data = "String".match(/.+/)

	assert_equal_ruby prettify(match_data), <<~RUBY.chomp
		MatchData("String")
	RUBY
end

test "custom inspect" do
	my_class = Class.new do
		def pretty_please(pp)
			pp.push "Custom["
			pp.map([1, 2, 3]) { |it| pp.capture { pp.prettify(it) } }
			pp.push "]"
		end
	end

	assert_equal_ruby prettify(my_class.new), <<~RUBY.chomp
		Custom[1, 2, 3]
	RUBY
end

test "ActiveRecord::Base Model" do
	assert_equal_ruby prettify(TestModel.new), <<~RUBY.chomp
		TestModel(
		  id: 1,
		  name: "Test Model",
		  created_at: Time("2025-02-06 01:02:03 UTC"),
		  updated_at: Time("2025-02-06 04:05:06 UTC"),
		  date: Date("2025-02-06"),
		  tags: ["tag_1", "tag_2", "tag_3"],
		  attribute_1: "value_1",
		  attribute_2: "value_2",
		  attribute_3: "value_3",
		  attribute_4: "value_4",
		  attribute_5: "value_5",
		  attribute_6: "value_6",
		  attribute_7: "value_7",
		  attribute_8: "value_8",
		  attribute_9: "value_9",
		)
	RUBY
end

test "Queue" do
	if RUBY_ENGINE == "truffleruby"
		assert_equal_ruby prettify(Queue.new), "Queue(size: 0)"
		assert_equal_ruby prettify(Queue.new.push(1)), "Queue(size: 1)"
	else
		assert_equal_ruby prettify(Queue.new), "Thread::Queue(size: 0)"
		assert_equal_ruby prettify(Queue.new.push(1)), "Thread::Queue(size: 1)"
	end
end

test "SizedQueue" do
	if RUBY_ENGINE == "truffleruby"
		assert_equal_ruby prettify(SizedQueue.new(10)), "SizedQueue(size: 0, max: 10)"
		assert_equal_ruby prettify(SizedQueue.new(10).push(1)), "SizedQueue(size: 1, max: 10)"
	else
		assert_equal_ruby prettify(SizedQueue.new(10)), "Thread::SizedQueue(size: 0, max: 10)"
		assert_equal_ruby prettify(SizedQueue.new(10).push(1)), "Thread::SizedQueue(size: 1, max: 10)"
	end
end
