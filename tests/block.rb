require_relative "../lib/numidium/block"

$test_block = Numidium.new(break_on_fail: true, raise: true, prefix: "block> ") do

	after -> (success) { puts success==0 && "Block method OK" || nil }

	add(Numidium.new(prefix: "block should ", break_on_fail: true) do
		before { @blocktest = Numidium.block { true } }

		add("return an array.") { @blocktest.is_a? Array }
		add("return an array with (at least) two elements") { @blocktest.length >= 2 }
		add("return a valid test") { @blocktest[0].is_a?(String) && @blocktest[1].respond_to?(:call) }
	end)

	add(Numidium.new(prefix: "block tests should ") do
		add("pass if empty.") do
			Numidium.block{ false }[1].call
		end

		add("pass if no assertion fails.") do
			Numidium.block{ assert{ true } }[1].call
		end

		add("fail if any assertion fails.") do
			!Numidium.block{ assert{ true }; assert{ false }; assert{ false } }[1].call
		end

		add("fail with the message given to the assert method") do
			Numidium.block("block"){ assert("assert"){ false } }[1].call == "assert"
		end

    add("use the test description") do
      Numidium.block("message"){ assert { false } }[0] == "message"
    end
	end)

	add(Numidium.new(prefix: "assert should be able to ") do
		add("deal with test atoms") do # Does this even make sense at all?
			Numidium.block{ assert("message", -> { true }) }[1].call
			Numidium.block{ assert("message", -> { false }) }[1].call == "message"
		end

		add("deal with test atom arrays") do
			Numidium.block{ assert(["message", -> { true }]) }[1].call
			Numidium.block{ assert(["message", -> { false }]) }[1].call == "message"
		end
	end)

	add("block_test should run a new test.") do
		res = Numidium.block_test do
			assert { false }
			assert { true }
			assert { false }
		end
		res == 1
	end
end
