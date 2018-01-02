require "nanotest"
require "nanotest/args"
require "nanotest/eval"

class OhMyGawdException < StandardError; end

# First of all check the integrity of the basic functionality:

passes = Nanotest.new do
  add "Test should fail", -> (test) { test.run==0 }
end

fails = Nanotest.new do
  add "Test should fail", -> (test) { test.run>0 }
end

raise "Something very basic is broken :(" if [
  passes.run(Nanotest.new(silent: true){ add "Truth should be truthy",->{ true } }),
  fails.run(Nanotest.new(silent: true){ add "Witchcraft should work",->{ "Witchcraft" == "Works" } }),
].any? { |e| e>0 }

Nanotest.run break_on_fail: true, prefix: "> " do
  add "Adding tests should work correctly", -> do
    t = Nanotest.new silent: true do
      add -> { true }
      add [
        -> { true },
        -> { true },
      ]
      add({
        "The world should make sense" => -> { 1 == 1 },
        "Math should make sense" => -> { 1 + 2 == 3 },
      })
    end
    t.run == 0
  end

  # Adding Subtests
  subtest = Nanotest.new
  subtest.add -> { 1 + 1 == 2 }
  subtest.add -> { 2 + 2 == 4 }
  sub subtest

  add "Should pass arguments of `run` to Subtests", -> do
    arguments = [1, "hello", :world]
    t = Nanotest.new silent: true do
      s = Nanotest.new(silent: true) {add ->(*args) {args == arguments}}
      sub s
    end
    t.run *arguments
  end

  subtest = Nanotest.new(message: "Tests break on fail behavior") do
    add "should break on fail", -> do
      var_test = false
      var_after = false
      Nanotest.run(silent: true, break_on_fail: true) do
        add -> { false }
        add -> { var_test = true }
        after ->(x) { var_after = true }
      end
      return "Did not break on fail" if var_test
      return "Did not run cleanup code" unless var_after
      return true
    end
  end
  sub subtest

  subtest = Nanotest.new(message: "Tests abort on fail behavior") do
    add "should break on fail", -> do
      var_test = false
      var_after = false
      Nanotest.run(silent: true, abort_on_fail: true) do
        add -> { false }
        add -> { var_test = true }
        after ->(x) { var_after = true }
      end
      return "Did not break on fail" if var_test
      return "Did not skip cleanup code" if var_after
      return true
    end
  end
  sub subtest

  add "Nanotest.run{} should pass aditional arguments", -> do
    (Nanotest.run({}, :hello, :world) do
      add ->(*args) { args == [:hello, :world] }
    end) == 0
  end

=begin
  //////// EVAL MODULE ////////
=end

  add "Test Eval::Truthy", -> {
    (Nanotest.run silent: true do
      add Nanotest::Eval::truthy "true"
      add Nanotest::Eval::truthy -> { true }
    end) == 0 and
    (Nanotest.run silent: true do
      add Nanotest::Eval::truthy "false"
      add Nanotest::Eval::truthy -> { false }
    end) == 2
  }

  add "Test Eval::Falsey", -> {
    (Nanotest.run silent: true do
      add Nanotest::Eval::falsey "false"
      add Nanotest::Eval::falsey -> { false }
    end) == 0 and
    (Nanotest.run silent: true do
      add Nanotest::Eval::falsey "true"
      add Nanotest::Eval::falsey -> { true }
    end) == 2
  }

  add "Test Eval::equal", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::equal "2+2", "4"
      add Nanotest::Eval::equal -> { true }, -> { not false }
    end) == 0 and
    (Nanotest.run silent: true do
      add Nanotest::Eval::equal "2+2", "5"
      add Nanotest::Eval::equal -> { :bananas }, -> { :potatoes }
    end) == 2
  end

  add "Test Eval::unequal", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::unequal "2+2", "4"
      add Nanotest::Eval::unequal -> { true }, -> { not false }
    end) == 2 and
    (Nanotest.run silent: true do
      add Nanotest::Eval::unequal "2+2", "5"
      add Nanotest::Eval::unequal -> { :bananas }, -> { :potatoes }
    end) == 0
  end

  add "Test Eval::succeeds", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::succeeds -> { return 1 + 1 }
    end) == 0 and
    (Nanotest.run silent: true do
      add Nanotest::Eval::succeeds -> { error "Hello World" }
    end) == 1
  end

  add "Test Eval::fails", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::fails -> { error "Hello World" }
    end) == 0 and
    (Nanotest.run silent: true do
      add Nanotest::Eval::fails -> { 1 + 1 == 2 }
    end) == 1
  end

  sub (Nanotest.new silent: false, message: "Test Eval::maps" do
    add({
      "Eval::maps should do its job" => -> do
        (Nanotest.run silent: true do
          add Nanotest::Eval::maps(->(x){x+1}, {[1]=>2, [2]=>3})
        end) == 0
      end
    })
    add({
      "Eval::maps should fail when the values don't match" => -> do
        (Nanotest.run silent: true do
          add Nanotest::Eval::maps(->(x){x+1}, {[1]=>3})
        end) == 1
      end
    })
  end)

  # Adding a before filter
  before -> { puts "Starting Test..." }

  # Adding an after filter
  after -> (success) { puts success ? "All good ♥" : "\nSomething went wrong :|" }
end
