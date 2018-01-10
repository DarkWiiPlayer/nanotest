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

Nanotest.run break_on_fail: true, raise: true, prefix: "> " do
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

  add "Test should fail when a subtest fails (#{__LINE__})", -> do
    test = Nanotest.new silent: true
    test.add Nanotest.new(silent: true) { add -> { false } }
    test.run >= 1
  end

  add "Test should succeed when no subtest fails (#{__LINE__})", -> do
    test = Nanotest.new silent: true
    test.add Nanotest.new(silent: true) { add -> { true } }
    test.run == 0
  end

  add "Should pass arguments of `run` to Subtests (#{__LINE__})", -> do
    arguments = [1, "hello", :world]
    t = Nanotest.new silent: true do
      s = Nanotest.new(silent: true) {add ->(*args) {args == arguments}}
      add s
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
  add subtest

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
  add subtest

  add "Nanotest.run{} should pass aditional arguments", -> do
    (Nanotest.run({}, :hello, :world) do
      add ->(*args) { args == [:hello, :world] }
    end) == 0
  end

  add Nanotest.new(message: "Tests should throw when the :throw option is set and they fail", silent: true) {
    add Nanotest::Eval::fails -> do
      Nanotest.run(silent: true, raise: true) { add -> { false } }
    end, exception: NanoTestFailed
  }

=begin
  //////// EVAL MODULE ////////
=end

  # Test boolean testing components

  add "Test Eval::truthy", -> {
    (Nanotest.run silent: true do
      add Nanotest::Eval::truthy "true"
      add Nanotest::Eval::truthy -> { true }
    end) == 0 and
    (Nanotest.run silent: true do
      add Nanotest::Eval::truthy "false"
      add Nanotest::Eval::truthy -> { false }
    end) == 2
  }

  add "Test Eval::falsey", -> {
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
  
  add (Nanotest.new message: "Test Eval::maps (#{__FILE__}:#{__LINE__})", prefix: "maps> " do
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
  after -> (success) { puts success==0 && "All good ♥" || nil }
end
