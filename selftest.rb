require "nanotest"
require "nanotest/args"
require "nanotest/eval"

# Verbose means "tell me what fails, what succeeds, and everything else".
Nanotest.run "Main", verbose: true do
  # Tests consist of a message and a lambda.

  # Tests succeed if the lambda evaluates to a truthy value that is not a string.
  add "One should equal One", -> {1 == 1}

  # Tests fail if they return nil or false.
  add "Witchcraft should work", -> { "Witchcraft" == "Works" }

  # Tests may return a custom fail message as well.
  add "This always fails", -> { return "This test just doesn't like you..." }

  # You can also pack tests into arrays.
  two_equals_two = ["Two should equal itself", -> { 2 == 2 }]
  add two_equals_two

  # Or build or include subtests and just add them with the sub method.
  subtest = Nanotest.new "Animals should be different"
  subtest << ["Cats should not be dogs", -> { "Cat" != "Dog" }]
  subtest << ["Cats should not be ducks", -> { "Cat" != "Duck" }]
  sub subtest
  sub Nanotest.new("Nanotest should be easy to use") << [
    "Adding subtests should require little typing", -> { true },
    "There should be nice syntax for anonymous subtests", -> { true },
  ]

  # The eval module provides some simple test factories that evaluate
  # string expressions or procs in an optional binding.
  var1 = "hello"
  var2 = "world"
  add *Nanotest::Eval::equal('var1', 'var2', binding: binding)
  add *Nanotest::Eval::fails(lambda {raise StandardError}, binding: binding)
  add *Nanotest::Eval::succeeds(<<~RUBY, binding: binding)
      puts "\t" + [var1,var2].join(", ")
  RUBY

  # You can also define tests and call them for different arguments.
  test_strings = Nanotest.new "sub", break_on_fail: true
  test_strings.add "Both imtems should be strings",
    -> (a,b) { a.is_a? String and b.is_a? String }
  # The Args module provides some basic tests that use arguments.
  test_strings.add *Nanotest::Args::unequal
  test_strings.add "Strings should have the same length", -> (a, b) do
    a.length == b.length
  end

  # sub passes all aditional arguments to subtest.run.
  sub test_strings, "hello", 20
  sub test_strings, "hello", "hello"
  sub test_strings, "hello", "world!"
  sub test_strings, "hello", "world"

  # You can also pass an array of tests...
  add [
    ["a should be a", -> {"a" == "a"}],
    ["a should not be z though", -> {"a" != "z"}],
    Nanotest::Eval::succeeds(-> {return false}),
    Nanotest::Eval::fails(-> {raise RuntimeError, "This proc hates you"}),
  ]

  # ...or a hash.
  class Cat; end
  class Dog; def quack; end; end
  add({
    "Cats should not bark" => -> { !Cat.new.respond_to? :bark },
    "Ducks should quack" => -> { Dog.new.respond_to? :quack },
  })

  # add setup and/or cleanup actions anywhere, they will be executed
  # in order at the beginning of the test.

  before -> { puts "=== Starting Test ===" }

  # variables must be "declared", that is, assigned to, or they would be block-local
  variable = nil
  after -> (s){ variable = "=== Tests " + (s ? "succeeded" : "failed") + " ===" }
  after -> (s){ puts variable }

  random_sub = Nanotest.new "Rnd. Subtest", random: true, notify_pass: true

  random_sub.add "First test", -> { true }
  random_sub.add "Second test", -> { true }
  random_sub.add "Third test", -> { true }

  sub random_sub

  # The ultimate test for expressions is the Eval::maps test.
  # It receives an expression, a table(hash)[, a binding [and some options(hash)]]
  # and passes if the expression maps each key of the table to its corresponding
  # value. Aditional arguments to the test are discarted.
  add *Nanotest::Eval::maps(
    -> (x) {x==5 ? 6 : x+2},
    {
      2 => 4,
      3 => 5,
      5 => 7, #ooops
    },
    message: "Should always add 2"
  )
end

Nanotest.run do
  add ["All good?", ->{ true }]
  after ->(s){ puts "All good :)" }
end
