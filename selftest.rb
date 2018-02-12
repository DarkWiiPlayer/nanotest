# vim: set noexpandtab:

# Test that the files are ok
if [ # TODO: Make this into a test module
	system("ruby -wc lib/numidium.rb"),
	system("ruby -wc lib/numidium/eval.rb"),
].any? { |e| !e } then
	raise "Some of the ruby files aren't okay :|"
end

require_relative "lib/numidium"
require_relative "lib/numidium/eval"

# First of all check the very basics are working

raise "Something very basic is broken :(" if [
	Numidium.run(silent: true){ add -> { true } } <1,
	Numidium.run(silent: true){ add -> { "Witchcraft" == "Works" } } >0,
].any? { |e| !e }

raise "Numidium can't count :(" unless Numidium.run(silent: true) {
	7.times {
		add -> { false }
	}
} == 7

begin
	raise NumidiumTestFailed, "Broken tests aren't counted as failed" if (Numidium.run silent: true do
		add -> { raise "an error" }
	end) != 1
rescue RuntimeError => e
	raise "Numidium doesn't catch exceptions right!"
end

Numidium.run(break_on_fail: true, raise: true, prefix: "> ") do
	add(Numidium::Eval::succeeds(message: "Setting options should work") do
		test = Numidium.new(raise: true)
		test.setop(raise: false)
		test.add { false }
		test.run
	end)

	add "try should return true if nothing fails" do
		Numidium.try { add { true } }
	end

	add "try should return false if something fails" do
		!Numidium.try { add { false } }
	end

	add("Adding tests should work correctly") do
		t = Numidium.new(silent: true) do
			add { true }
			add [
				-> { true },
				-> { true },
			]
			add({
				"The world should make sense" => lambda { 1 == 1 },
				"Math should make sense" => lambda { 1 + 2 == 3 },
			})
		end
		t.run == 0
	end

	# Adding Subtests

	add("Test should fail when a subtest fails (#{__LINE__})") do
		test = Numidium.new silent: true
		test.add(Numidium.new(silent: true) { add { false } })
		test.run >= 1
	end

	add("Test should succeed when no subtest fails (#{__LINE__})") do
		test = Numidium.new(silent: true)
		test.add(Numidium.new(silent: true) { add { true } })
		test.run == 0
	end

	add("Numidium.run{} should pass aditional arguments to tests") do
		(Numidium.run({}, :hello, :world) do
			add { |*args| args == [:hello, :world] }
		end) == 0
	end

	add("Numidium.run{} should pass aditional arguments to subtests") do
		arguments = [1, "hello", :world]
		t = Numidium.new(silent: true) do
			s = Numidium.new(silent: true) { add { |*args| args == arguments } }
			add s
		end
		t.run(*arguments) == 0
	end

	add(Numidium.new(message: "Tests break on fail behavior", prefix: "Test ") do
		add "should break on fail", -> do
			var_test = false
			var_after = false
			Numidium.run(silent: true, break_on_fail: true) do
				add { false }
				add { var_test = true }
				cleanup { var_after = true }
			end
			return "did not break on fail" if var_test
			return "did not run cleanup code" unless var_after
			return true
		end
	end)

	add(Numidium.new(message: "Tests abort on fail behavior") do
		add "should break on fail", -> do
			var_test = false
			var_after = false
			Numidium.run(silent: true, abort_on_fail: true) do
				add { false }
				add { var_test = true }
				cleanup { var_after = true }
			end
			return "Did not break on fail" if var_test
			return "Did not skip cleanup code" if var_after
			return true
		end
	end)

	add(Numidium.new(message: ":raise should make failed tests raise an error", silent: true) do
		add(Numidium::Eval::fails(exception: NumidiumTestFailed) do
			Numidium.run(silent: true, raise: true) { add { false } }
		end)
	end)

=begin
	//////// EVAL MODULE ////////
=end

	# Test boolean testing components

	add(Numidium.new(prefix: "Eval::truthy should evaluate ") do
		add("true string espressions as pass") do
			not Numidium::Eval::truthy("true")[1].call.is_a? String
		end
		add("true lambda espressions as pass") do
			not Numidium::Eval::truthy(->{ true })[1].call.is_a? String
		end
		add("false string espressions as fail") do
			Numidium::Eval::truthy("false")[1].call.is_a? String
		end
		add("false lambda espressions as fail") do
			Numidium::Eval::truthy(->{ false })[1].call.is_a? String
		end
	end)

	add(Numidium.new(prefix: "Eval::falsey should evaluate ") do
		add("false string espressions as pass") do
			not Numidium::Eval::falsey("false")[1].call.is_a? String
		end
		add("false lambda espressions as pass") do
			not Numidium::Eval::falsey(->{ false })[1].call.is_a? String
		end
		add("true string espressions as fail") do
			Numidium::Eval::falsey("true")[1].call.is_a? String
		end
		add("true lambda espressions as fail") do
			Numidium::Eval::falsey(->{ true })[1].call.is_a? String
		end
	end)

	add(Numidium.new(prefix: "Eval::equal should evaluate") do
		add("equivalent string expressions as pass") do
			Numidium::Eval::equal("true", "!false")[1].call
		end
		add("equivalent lambdas expressions as pass") do
			Numidium::Eval::equal(->{true}, ->{!false})[1].call
		end
		add("inequivalent string expressions as fail") do
			Numidium::Eval::equal("true", "!false")[1].call
		end
		add("inequivalent lambdas expressions as fail") do
			Numidium::Eval::equal(->{true}, ->{!false})[1].call
		end
	end)

	add "Test Eval::equal #{__LINE__}" do
		(Numidium.run silent: true do
			add Numidium::Eval::equal "2+2", "4"
			add Numidium::Eval::equal -> { true }, -> { not false }
		end) == 0 and
		(Numidium.run silent: true do
			add Numidium::Eval::equal "2+2", "5"
			add Numidium::Eval::equal -> { :bananas }, -> { :potatoes }
		end) == 2
	end

	add "Test Eval::unequal" do
		(Numidium.run silent: true do
			add Numidium::Eval::unequal "2+2", "4"
			add Numidium::Eval::unequal -> { true }, -> { not false }
		end) == 2 and
		(Numidium.run silent: true do
			add Numidium::Eval::unequal "2+2", "5"
			add Numidium::Eval::unequal -> { :bananas }, -> { :potatoes }
		end) == 0
	end

	# Test exception testing components

	add(Numidium.new(prefix: "Eval::succeeds ") do
		add("should succeed if nothing is raised.", lambda do
			Numidium::Eval::succeeds(lambda do
				1 + 1 == 2
			end)[1].call
		end)
		add("should fail if the 'expected' exception is raised.", lambda do
			Numidium::Eval::succeeds(lambda do
				raise ArgumentError
			end, exception: ArgumentError)[1].call == false
		end)
		add Numidium::Eval::fails(lambda do
			Numidium::Eval::succeeds(lambda do
				raise "It's the end of the world as we know it!"
			end, exception: ArgumentError)[1].call == false
		end,
		message: "should not catch other exceptions and let core deal with them."
		)
	end)

	add(Numidium.new(prefix: "Eval::fails ") do
		add("should succeed when an error is raised", lambda do
			(Numidium.run(silent: true) do
				add Numidium::Eval::fails -> { raise "Hello World" }
			end) == 0
		end)

		add("should fail when no error is raised", lambda do
			(Numidium.run(silent: true) do
				add Numidium::Eval::fails -> { 1 + 1 == 2 }
			end) == 1
		end)

		add("should succeed when the right exception is raised", lambda do
			(Numidium.run(silent: true) do
				add Numidium::Eval::fails(
					-> { raise ArgumentError },
					exception: ArgumentError
				)
			end) == 0
		end)

		add("should fail when a wrong exception is raised", lambda do
			(Numidium.run(silent: true) do
				add Numidium::Eval::fails(
					-> { raise ArgumentError },
					exception: RuntimeError
				)
			end) == 1
		end)
	end)

	# Test result testing components
	
	add "Eval::maps should return a single test" do
		Numidium::Eval::maps({:a => :a}, ->(x){ :a })[1].respond_to? :call
	end

	add "Eval::maps should return individual tests if :split is set" do
		maps_test = Numidium::Eval::maps({:a => :a}, ->(x){ :a }, split: true)
		maps_test.all? { |test| test[1].respond_to? :call }
	end
	
	add (Numidium.new( prefix: "Eval::maps should ", break_on_fail: true) do
		add({
			"succeed if a lambda maps a series of value tuples to the corresponding results" => lambda do
				Numidium::Eval::maps(
					{
						[1]=>2,
						[2]=>3,
					},
					-> (x){x+1}
				)[1].call
			end,

			"succeed if a block maps a series of value tuples to the corresponding results" => lambda do
				(Numidium::Eval::maps(
					{
						[1]=>2,
						[2]=>3,
					}) { |x| x+1 }
				)[1].call
			end,

			"succeed when an the expected result is raised instead of returned" => lambda do
				!!Numidium::Eval::maps({ [:a]=>NoMethodError }, ->(x){x+1})[1].call
			end,

			"ignore exceptions if the noraise option is set" => lambda do
				Numidium::Eval::fails do
					Numidium::Eval::maps({[:a]=>NoMethodError},->(x){nil + 2}, noraise: true)[1].call
				end[1].call
			end,
			
			"fail when a lambda doesn't match the map" => lambda do
				Numidium::Eval::maps({[1]=>3}, ->(x){ x+1 })[1].call.is_a? String
			end,

			"fail when a block doesn't match the map" => lambda do
				Numidium::Eval::maps({[1]=>3}){ |x| x+1 }[1].call.is_a? String
			end
		})
		add(Numidium::Eval::succeeds(message: "not crash when mapping non-array to value") do
			Numidium::Eval::maps({:a=>:a}, ->(a){a})[1].call()
		end)

		add "deal with non-array arguments" do
			not Numidium::Eval::maps({:a=>:a}, ->(a){a})[1].call().is_a?(String)
		end

		add "use a name if one is given" do
			not Numidium::Eval::maps({:a=>:b}, ->(a){a}, name: "yo mama")[1].call().match("yo mama").nil?
		end
	end)

	# Adding a before filter
	before -> { puts "Starting Test..." }

	# Adding an after filter
	after -> (success) { puts success==0 && "All good ♥" || nil }
end
