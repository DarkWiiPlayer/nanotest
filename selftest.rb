require_relative "lib/nanotest"
require_relative "lib/nanotest/args"
require_relative "lib/nanotest/eval"

class OhMyGawdException < StandardError; end

# First of all check the very basics are working

raise "Something very basic is broken :(" if [
  Nanotest.run(silent: true){ add -> { true } } < 1,
  Nanotest.run(silent: true){ add -> { "Witchcraft" == "Works" } } > 0,
].any? { |e| !e }

raise "Nanotest can't count :(" unless Nanotest.run(silent: true) {
  7.times {
    add -> { false }
  }
} == 7

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

  add "Test should fail when a subtest fails", -> do
    test = Nanotest.new silent: true
    test.sub Nanotest.new(silent: true) { add -> { false } }
    test.run > 0
  end

  add "Test should succeed when no subtest fails", -> do
    test = Nanotest.new silent: true
    test.sub Nanotest.new(silent: true) { add -> { true } }
    test.run < 1
  end

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

  # Test boolean testing components

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

  # Test exception testing components

  add "Eval::succeeds should succeed when no error is risen (#{__FILE__}:#{__LINE__})", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::succeeds -> { return 1 + 1 }
    end) == 0
  end
  add "Eval::succeeds should fail when an error is risen (#{__FILE__}:#{__LINE__})", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::succeeds -> { raise "Hello World" }
    end) == 1
  end

  add "Eval::succeeds should detect the right exception (#{__FILE__}:#{__LINE__})", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::succeeds(-> { raise ArgumentError }, exception: ArgumentError)
    end) == 1
  end
  add "Eval::succeeds should not detect a different exception (#{__FILE__}:#{__LINE__})", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::succeeds(-> { raise RuntimeError }, exception: ArgumentError)
    end) == 0
  end

  add "Eval::fails should succeed when an error is risen (#{__FILE__}:#{__LINE__})", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::fails -> { raise "Hello World" }
    end) == 0
  end
  add "Eval::fails should fail when no error is risen (#{__FILE__}:#{__LINE__})", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::fails -> { 1 + 1 == 2 }
    end) == 1
  end

  add "Eval::fails should detect the right exception (#{__FILE__}:#{__LINE__})", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::fails(-> { raise ArgumentError }, exception: ArgumentError)
    end) == 0
  end
  add "Eval::fails should not detect a different exception (#{__FILE__}:#{__LINE__})", -> do
    (Nanotest.run silent: true do
      add Nanotest::Eval::fails(-> { raise RuntimeError }, exception: ArgumentError)
    end) == 1
  end

  # Test result testing components
  
  sub (Nanotest.new message: "Test Eval::maps (#{__FILE__}:#{__LINE__})", prefix: "maps> " do
    add({
      "Eval::maps should check if the function maps a series of value tuples to the corresponding results" => -> do
        (Nanotest.run silent: true do
          add Nanotest::Eval::maps(
            ->(x){x+1}, {
              [1]=>2,
              [2]=>3,
            })
        end) == 0
      end,

      "Eval::maps should react to exceptions" => -> do
        (Nanotest.run do
          add Nanotest::Eval::maps(
            ->(x){x+1}, {
              [:a]=>NoMethodError,
            })
        end) == 0
      end,

      "Eval::maps should not react to exceptions if the noraise option is set" => -> do
        (Nanotest.run silent: true do
          add Nanotest::Eval::maps(
            ->(x){x+1}, {
              [:a]=>NoMethodError,
            }, noraise: true)
        end) == 1
      end,
      
      "Eval::maps should fail when the values don't match (#{__FILE__}:#{__LINE__}" => -> do
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
  after -> (success) { raise RuntimeError unless success }
end
