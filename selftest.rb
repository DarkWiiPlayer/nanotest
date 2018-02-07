# vim: set noexpandtab:

# Test that the files are ok
if [ # TODO: Make this into a test module
	system("ruby -wc lib/nanotest.rb"),
	system("ruby -wc lib/nanotest/eval.rb"),
].any? { |e| !e } then
	raise "Some of the ruby files aren't okay :|"
end

require_relative "lib/nanotest"
require_relative "lib/nanotest/eval"

# First of all check the very basics are working

raise "Something very basic is broken :(" if [
	Nanotest.run(silent: true){ add -> { true } } <1,
	Nanotest.run(silent: true){ add -> { "Witchcraft" == "Works" } } >0,
].any? { |e| !e }

raise "Nanotest can't count :(" unless Nanotest.run(silent: true) {
	7.times {
		add -> { false }
	}
} == 7

begin
	raise NanoTestFailed, "Broken tests aren't counted as failed" if (Nanotest.run silent: true do
		add -> { raise "an error" }
	end) != 1
rescue RuntimeError => e
	raise "Nanotest doesn't catch exceptions right!"
end

Nanotest.run(break_on_fail: true, raise: true, prefix: "> ") do
	add(Nanotest::Eval::succeeds(message: "Setting options should work") do
		test = Nanotest.new(raise: true)
		test.setop(raise: false)
		test.add { false }
		test.run
	end)

	add("Adding tests should work correctly") do
		t = Nanotest.new(silent: true) do
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
		test = Nanotest.new silent: true
		test.add(Nanotest.new(silent: true) { add { false } })
		test.run >= 1
	end

	add("Test should succeed when no subtest fails (#{__LINE__})") do
		test = Nanotest.new(silent: true)
		test.add(Nanotest.new(silent: true) { add { true } })
		test.run == 0
	end

	add("Nanotest.run{} should pass aditional arguments to tests") do
		(Nanotest.run({}, :hello, :world) do
			add { |*args| args == [:hello, :world] }
		end) == 0
	end

	add("Nanotest.run{} should pass aditional arguments to subtests") do
		arguments = [1, "hello", :world]
		t = Nanotest.new(silent: true) do
			s = Nanotest.new(silent: true) { add { |*args| args == arguments } }
			add s
		end
		t.run(*arguments) == 0
	end

	add(Nanotest.new(message: "Tests break on fail behavior", prefix: "Test ") do
		add "should break on fail", -> do
			var_test = false
			var_after = false
			Nanotest.run(silent: true, break_on_fail: true) do
				add { false }
				add { var_test = true }
				cleanup { var_after = true }
			end
			return "did not break on fail" if var_test
			return "did not run cleanup code" unless var_after
			return true
		end
	end)

	add(Nanotest.new(message: "Tests abort on fail behavior") do
		add "should break on fail", -> do
			var_test = false
			var_after = false
			Nanotest.run(silent: true, abort_on_fail: true) do
				add { false }
				add { var_test = true }
				cleanup { var_after = true }
			end
			return "Did not break on fail" if var_test
			return "Did not skip cleanup code" if var_after
			return true
		end
	end)

	add(Nanotest.new(message: ":raise should make failed tests raise an error", silent: true) do
		add(Nanotest::Eval::fails(exception: NanoTestFailed) do
			Nanotest.run(silent: true, raise: true) { add { false } }
		end)
	end)

=begin
	//////// EVAL MODULE ////////
=end

	# Test boolean testing components

	add(Nanotest.new(prefix: "Eval::truthy should evaluate ") do
		add("true string espressions as pass") do
			not Nanotest::Eval::truthy("true")[1].call.is_a? String
		end
		add("true lambda espressions as pass") do
			not Nanotest::Eval::truthy(->{ true })[1].call.is_a? String
		end
		add("false string espressions as fail") do
			Nanotest::Eval::truthy("false")[1].call.is_a? String
		end
		add("false lambda espressions as fail") do
			Nanotest::Eval::truthy(->{ false })[1].call.is_a? String
		end
	end)

	add(Nanotest.new(prefix: "Eval::falsey should evaluate ") do
		add("false string espressions as pass") do
			not Nanotest::Eval::falsey("false")[1].call.is_a? String
		end
		add("false lambda espressions as pass") do
			not Nanotest::Eval::falsey(->{ false })[1].call.is_a? String
		end
		add("true string espressions as fail") do
			Nanotest::Eval::falsey("true")[1].call.is_a? String
		end
		add("true lambda espressions as fail") do
			Nanotest::Eval::falsey(->{ true })[1].call.is_a? String
		end
	end)

	add(Nanotest.new(prefix: "Eval::equal should evaluate") do
		add("equivalent string expressions as pass") do
			Nanotest::Eval::equal("true", "!false")[1].call
		end
		add("equivalent lambdas expressions as pass") do
			Nanotest::Eval::equal(->{true}, ->{!false})[1].call
		end
		add("inequivalent string expressions as fail") do
			Nanotest::Eval::equal("true", "!false")[1].call
		end
		add("inequivalent lambdas expressions as fail") do
			Nanotest::Eval::equal(->{true}, ->{!false})[1].call
		end
	end)

	add "Test Eval::equal #{__LINE__}" do
		(Nanotest.run silent: true do
			add Nanotest::Eval::equal "2+2", "4"
			add Nanotest::Eval::equal -> { true }, -> { not false }
		end) == 0 and
		(Nanotest.run silent: true do
			add Nanotest::Eval::equal "2+2", "5"
			add Nanotest::Eval::equal -> { :bananas }, -> { :potatoes }
		end) == 2
	end

	add "Test Eval::unequal" do
		(Nanotest.run silent: true do
			add Nanotest::Eval::unequal "2+2", "4"
			add Nanotest::Eval::unequal -> { true }, -> { not false }
		end) == 2 and
		(Nanotest.run silent: true do
			add Nanotest::Eval::unequal "2+2", "5"
			add Nanotest::Eval::unequal -> { :bananas }, -> { :potatoes }
		end) == 0
	end

	# Test exception testing components

	add(Nanotest.new(prefix: "Eval::succeeds ") do
		add("should succeed if nothing is raised.", lambda do
			Nanotest::Eval::succeeds(lambda do
				1 + 1 == 2
			end)[1].call
		end)
		add("should fail if the 'expected' exception is raised.", lambda do
			Nanotest::Eval::succeeds(lambda do
				raise ArgumentError
			end, exception: ArgumentError)[1].call == false
		end)
		add Nanotest::Eval::fails(lambda do
			Nanotest::Eval::succeeds(lambda do
				raise "It's the end of the world as we know it!"
			end, exception: ArgumentError)[1].call == false
		end,
		message: "should not catch other exceptions and let core deal with them."
		)
	end)

	add(Nanotest.new(prefix: "Eval::fails ") do
		add("should succeed when an error is raised", lambda do
			(Nanotest.run(silent: true) do
				add Nanotest::Eval::fails -> { raise "Hello World" }
			end) == 0
		end)

		add("should fail when no error is raised", lambda do
			(Nanotest.run(silent: true) do
				add Nanotest::Eval::fails -> { 1 + 1 == 2 }
			end) == 1
		end)

		add("should succeed when the right exception is raised", lambda do
			(Nanotest.run(silent: true) do
				add Nanotest::Eval::fails(
					-> { raise ArgumentError },
					exception: ArgumentError
				)
			end) == 0
		end)

		add("should fail when a wrong exception is raised", lambda do
			(Nanotest.run(silent: true) do
				add Nanotest::Eval::fails(
					-> { raise ArgumentError },
					exception: RuntimeError
				)
			end) == 1
		end)
	end)

	# Test result testing components
	
	add (Nanotest.new(
		prefix: "Eval::maps should ",
		break_on_fail: true
	) do
		add({
			"succeed if a lambda maps a series of value tuples to the corresponding results" => lambda do
				Nanotest::Eval::maps(
					{
						[1]=>2,
						[2]=>3,
					},
					-> (x){x+1}
				)[1].call
			end,

			"succeed if a block maps a series of value tuples to the corresponding results" => lambda do
				(Nanotest::Eval::maps(
					{
						[1]=>2,
						[2]=>3,
					}) { |x| x+1 }
				)[1].call
			end,

			"succeed when an the expected result is raised instead of returned" => lambda do
				!!Nanotest::Eval::maps({ [:a]=>NoMethodError }, ->(x){x+1})[1].call
			end,

			"ignore exceptions if the noraise option is set" => lambda do
				Nanotest::Eval::fails do
					Nanotest::Eval::maps({[:a]=>NoMethodError},->(x){nil + 2}, noraise: true)[1].call
				end[1].call
			end,
			
			"fail when a lambda doesn't match the map" => lambda do
				Nanotest::Eval::maps({[1]=>3}, ->(x){ x+1 })[1].call.is_a? String
			end,

			"fail when a block doesn't match the map" => lambda do
				Nanotest::Eval::maps({[1]=>3}){ |x| x+1 }[1].call.is_a? String
			end
		})
		add(Nanotest::Eval::succeeds(message: "not crash when mapping non-array to value") do
			Nanotest::Eval::maps({:a=>:a}, ->(a){a})[1].call()
		end)

		add "deal with non-array arguments" do
			not Nanotest::Eval::maps({:a=>:a}, ->(a){a})[1].call().is_a?(String)
		end

		add "use a name if one is given" do
			not Nanotest::Eval::maps({:a=>:b}, ->(a){a}, name: "yo mama")[1].call().match("yo mama").nil?
		end
	end)

	# Adding a before filter
	before -> { puts "Starting Test..." }

	# Adding an after filter
	after -> (success) { puts success==0 && "All good ♥" || nil }
end
