require_relative "../lib/numidium"
require_relative "../lib/numidium/eval"

$test_core = Numidium.new(break_on_fail: true, raise: true, prefix: "core> ") do

	after -> (success) { puts success==0 && "Core class is OK" || nil }

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

	add("all ways of adding tests should work") do
		t = Numidium.new(silent: true) do
			add { true }
      add -> { true }
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

	add("a test should fail when a subtest fails (#{__LINE__})") do
		test = Numidium.new silent: true
		test.add(Numidium.new(silent: true) { add { false } })
		test.run >= 1
	end

	add("a test should succeed when no subtest fails (#{__LINE__})") do
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

	add(Numidium.new(message: ":break_on_fail should work", prefix: "Test ") do
		add "should break on fail", -> do
			var_test = false
			var_after = false
			Numidium.run(silent: true, break_on_fail: true) do
				add { false }
				add { var_test = true }
				cleanup { var_after = true }
			end
			return "Test did not break on fail" if var_test
			return "Test did not run cleanup code" unless var_after
			return true
		end
	end)

	add(Numidium.new(message: ":abort_on_fail should work") do
		add "should break on fail", -> do
			var_test = false
			var_after = false
			Numidium.run(silent: true, abort_on_fail: true) do
				add { false }
				add { var_test = true }
				cleanup { var_after = true }
			end
			return "Test did not break on fail" if var_test
			return "Test did not skip cleanup code" if var_after
			return true
		end
	end)

	add(Numidium.new(message: ":raise should make failed tests raise an error", silent: true) do
		add(Numidium::Eval::fails(exception: NumidiumTestFailed) do
			Numidium.run(silent: true, raise: true) { add { false } }
		end)
	end)
end
