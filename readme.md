Numidium
==========================================================================================

Note: Numidium has been completely rebuilt in version 0.6!

Numidium is a Library mainly intended for [TDD](https://en.wikipedia.org/wiki/Test-driven_development). The core principiles of Numidium are
- Simplicity of Implementation: doing more things with less code / classes.
- Simplicity of Use: offering more options in less idioms.
- Flexibility: allowing for more while needing less boilerplate.
- Modularity: a small core implementation and some modules stacked on top of it.

As a result of this, Numidium consists of a very small "core", implementing concepts like "tests", "assertions" and "test suites". To avoid needless complexity, Numidium doesn't reinvent the wheel.
There are no "equals" or "is_type" assertions, because there is equally convenient ruby methods that do exactly that. There are, however, a few factory functions that generate more high-level tests.

Concepts
==========================================================================================

Assertions & Failure Conditions
-----------------------------------------

These serve as abstractions for the lowest level elements like states, operations, variables, etc. They appear inside tests in the form of method calls.

```ruby
assert("Hamlet should be the protagonist") { protagonist == "Hamlet" }
fail("Not everybody died by the end") unless characters.reject{|c| c.alive?}.empty
```

The key differences are:
  - Assertions describe desired behavior vs. fail informs of what went wrong
  - Assertions should always execute vs. fail should be attached to a condition (ie. `if`)
  - Assertions inform of both success and failure vs. fail always fails (duh!)

Tests
-----------------------------------------

Numidium tests represent smaller features and functionalities. They can take parameters, which is recommended in all but the smallest ad-hoc tests. Tests are created with a string describing them and a block or callable object defining the test.

Suites
-----------------------------------------

Suites provide the highest level of abstraction in Numidium. They represent entire components or features of a project.

Unlike tests, suites will almost exclusively be project-specific.

In Practice
==========================================================================================

Tests
-----------------------------------------

Tests can be created easily, they take a string argument, and either a block or an argument that responds to `:call`. The order of the arguments does not matter.

```ruby
test_qualified = Nanotest::Test.new("Actor should be qualified") do |actor, role|
  assert("Actor and Role should be about the same age") { (actor.age - role.age).abs < 10 }
  assert("Actor should be skilled enough") { actor.skill >= role.required_skill}
end
...
puts test_qualified.run("Gérard Depardieu", "Edmond Dantès")
```

Test descriptions *should* describe the desired behavior, similar to assertions.

### Using tests

Tests can be executed in two ways: `run`, which generates a report object and `try`, which only generates a result object. Report objects collect data about the individual assertions and is able to convert this data to a string. Result objects on the other hand only contain success data (true or false) and a message describing the result. They can either be used when we only want to know if a test succeeded.

```ruby
if test_qualified.try("me", "myself").success then
  puts "Success!"
else
  puts "Oh no!"
end
```

### Subtests
But what would tests be without newting? That's why you can add subtests to tests.

When defining a test, you can use the `test` method to add another Numidium::Test instance as a subtest. Its report will be inserted into the main one and indented with two spaces for easier reading.

The method `try` does almost the same, but instead of generating a new report, it calls `try` on the inserted test, so the main report will only contain a message telling you whether the test passed or not.

### Prettier Descriptions

Before passing the description to the report object it feeds it througn sprintf with the arguments of run(). Since sprintf fails when not enough arguments are provided for a string, it is recommended to only do this in combination with lambdas:

```ruby
test_animal_fast = Nanotest::Test.new("%s should be fast") |animal|
  assert { animal.speed > 20 }
end

test_animal_fast.run(rabbit) #-> this works
test_animal_fast.run(dolphin, :nonsense) #-> this works too
test_animal_fast.run() #-> this fails horribly though
```

Suites
-----------------------------------------

Suites are created with a Hash of options. So far the only accepted option is `:description`, which should be a string describing what the suite does, what component it tests, etc.

Suite descriptions should tell you what the suite does or what it tests

```ruby
test_suite_math = Numidium::Suite.new ""
```

Examples
===
Here's a short example of a rather pointless test scenario. In this case we want to make sure math still works in ruby.

```ruby
require_relative "lib/numidium"
require_relative "lib/numidium/suite"

eval_test =
  Numidium::Test.new "%s should equal %i" do |expr, result|
    res = eval(expr)
    fail "Evaluated to #{res}!" unless res == result
  end

test_suite_math = Numidium::Suite.new description: "Check if math works" do
  try eval_test, "1 + 1", 2
  try eval_test, "1 + 2", 3
  try eval_test, "1 - 2", -3 # Ooops!
end

rep = test_suite_math.run
out =
  if rep.success then
    rep.to_s + "\n" +
    "All tests passed :)"
  else
    rep.to_s + "\n" +
    "Some tests failed :|"
  end
puts out
```

but it seems the programmer made a [last line mistake](https://www.viva64.com/en/b/0260/) in that code.

The output of that code would look somewhat like this:

```
Check if math works
===============

 Test passed: 1 + 1 should equal 2

 Test passed: 1 + 2 should equal 3

>Test failed: 1 - 2 should equal -3
   ./lib/numidium/suite.rb:34:in `block in run'
   ./lib/numidium/suite.rb:33:in `each'
   ./lib/numidium/suite.rb:33:in `run'
   suite.rb:16:in `<main>'
Some tests failed :|
```

Since the test constructs the message from its parameters, the error in the test parameters is reflected in its output, making it easy to spot as a copy-paste mistake.
