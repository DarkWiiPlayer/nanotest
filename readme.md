Numidium
==========================================================================================

Note: Numidium has been completely rebuilt in version 0.6!

Numidium is a Library mainly intended for [TDD](https://en.wikipedia.org/wiki/Test-driven_development). The core principiles of Numidium are
- Simplicity of Implementation: doing more things with less code / classes.
- Simplicity of Use: offering more options in less idioms.
- Flexibility: allowing for more while needing less boilerplate.
- Modularity: a small core implementation and some modules stacked on top of it.

As a result of this, Numidium consists of a very small "core", implementing concepts like "tests", "assertions" and "test suites". To avoid needless complexity, Numidium doesn't reinvent the wheel.
There are no "equals" or "is_type" assertions, because there is equally convenient ruby methods that do exactly that. There are, however, a few factory functions that generate more high-level tests. (more like there *will* be tehe~)

TODOs
==========================================================================================

- Write tests in plain ruby -- started
- Write some examples
- Add prefab tests

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

Like when defining tests, it also has the `try` and `test` methods, which add tests to a list that will get executed once the `run` method is called.

Suite descriptions should tell you what the suite does or what it tests

```ruby
test_suite_math = Numidium::Suite.new "Check that math module works correctly"
test_suite_math.test some_previously_defined_test
test_suite_math.try some_previously_defined_test
```

Examples
===
Here's a short example of a rather pointless test scenario. In this case we want to make sure math still works in ruby.

```ruby
require "lib/numidium"
require "lib/numidium/suite"

expr_test =
  Numidium::Test.new "expression %s should equal %i" do |expr, result|
    res = eval(expr)
    assert("expression %s should equal %i") { res == result }
  end

test_suite_math = Numidium::Suite.new description: "Check if math works" do
  try expr_test, "1 + 1", 2
  try expr_test, "1 + 2", 3
  try expr_test, "1 - 2", -3 # Ooops!
end

rep = test_suite_math.run

puts rep.tap.join("\n")
puts "-----------------"
puts rep
```

but it seems the programmer made a [last line mistake](https://www.viva64.com/en/b/0260/) in that code.

The output of that code would look somewhat like this:

```
1..3
ok 1 expression 1 + 1 should equal 2
ok 2 expression 1 + 2 should equal 3
not ok 3 expression 1 - 2 should equal -3
-----------------
Check if math works
+ expression 1 + 1 should equal 2
+ expression 1 + 2 should equal 3
- expression 1 - 2 should equal -3
>   [...]/suite.rb:35:in `block in run'
>   [...]/suite.rb:34:in `each'
>   [...]/suite.rb:34:in `run'
>   suite.rb:16:in `<main>'
```

Since the test constructs the message from its parameters, the error in the test parameters is reflected in its output, making it easy to spot as a copy-paste mistake.
