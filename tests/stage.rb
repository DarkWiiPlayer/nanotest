require_relative "../lib/numidium/stage"

module EnumerableOnly
  refine Enumerable do
    def only
      raise "Expected #{self.class} to only have one element (has #{length})" unless length == 1
      first
    end
  end
end
using EnumerableOnly

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
	end).is_a? Array
end

assert "fail should register a failed test" do
  not Numidium::Stage.new.evaluate(proc do
    fail "Cuz Reaons, you know?"
  end).only.success
end

assert "pass should register a passed test" do
  Numidium::Stage.new.evaluate(proc do
    pass "Cuz Reaons, you know?"
  end).only.success
end

assert "assert should return the success within the test" do
  Numidium::Stage.new.evaluate(proc do
    assert { assert { true } == true }
    assert { assert { false } == false }
  end).count{ |r| !r.success }
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

assert "skip should create a skip result" do
  Numidium::Stage.new.evaluate(proc do
    skip "reasons"
  end).only.type == :skip
end

assert "given should change nothing when condition is met" do
  Numidium::Stage.new.evaluate(proc do
    given true do
      pass "yes"
    end
  end).only.type == :pass
end

assert "given should change assert to skip" do
  Numidium::Stage.new.evaluate(proc do
    given false do
      assert("<description>") { true }
    end
  end).only.type == :skip
end

assert "given should work when nested" do
  Numidium::Stage.new.evaluate(proc do
    given(false) { given(false) { assert("") { false } } }
  end).only.type == :skip
end

assert "given should still change nothing when nested" do
  Numidium::Stage.new.evaluate(proc do
    given(true) { given(true) { assert("") {false} } }
  end).only.type == :fail
end
