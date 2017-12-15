require "nanotest"
require "nanotest/args"
require "nanotest/eval"

class OhMyGawdException < StandardError; end

# First of all check the integrity of the basic functionality:

passes = Nanotest.new do
  add "Test should fail", -> (test) { test.run }
end

fails = Nanotest.new do
  add "Test should fail", -> (test) { !test.run }
end

raise "Something very basic is broken :(" if [
  passes.run(Nanotest.new(silent: true){ add "Truth should be truthy",->{ true } }),
  fails.run(Nanotest.new(silent: true){ add "Witchcraft should work",->{ "Witchcraft" == "Works" } }),
].any? { |e| !e }

Nanotest.run break_on_fail: true, prefix: "> " do
  #TODO: Make these an actual test case
 
  # Adding a single test
  add -> {true}

  # Adding an array of tests
  add [
    -> { true },
    -> { 1+1==2 },
  ]
  # Adding a hash of tests
  add({
    "The world should make sense" => -> { 1 == 1 },
    "Math should make sense" => -> { 1 + 2 == 3 },
  })

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

  # Adding a before filter
  before -> { puts "Starting Test..." }

  # Adding an after filter
  after ->(success) { puts success ? "All good ♥" : "Something went wrong :|" }
end
