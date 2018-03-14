require_relative "../lib/numidium/stage"

assert("Numidium::Stage should be defined") { defined? Numidium::Stage }
assert("Numidium::Stage should be a class") { Numidium::Stage.is_a? Class }

assert "Stages should evaluate blocks" do
	var = 1
	Numidium::Stage.new.evaluate(proc do
		var = 2
	end)
	var == 2
end

assert "Calling `events` on an unused stage should raise an error" do
	Numidium::Stage.new.events
	false
rescue
	true
end

assert "evaluate should catch exceptions" do
	Numidium::Stage.new.evaluate(proc do
		raise "I am an error! Raaaaawr!"
	end)
end

assert "Evaluate should return an array of events" do
	Numidium::Stage.new.evaluate(proc do
		fail "'cuz reasons"
	end).is_a? Array
end

assert "assert should not abort test runs when it succeeds" do
	var = 1
	Numidium::Stage.new.evaluate(proc do
		assert { true }
		var = 2
	end)
	var == 2
end

assert "assert should not abort test runs when it fails" do
	var = 1
	Numidium::Stage.new.evaluate(proc do
		assert { false }
		var = 2
	end)
	var == 2
end

assert "fail should not abort test runs" do
	var = 1
	Numidium::Stage.new.evaluate(proc do
		fail "reason"
		var = 2
	end)
	var == 2
end
