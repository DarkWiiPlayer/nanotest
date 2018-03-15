Numidium [![Build Status](https://travis-ci.org/DarkWiiPlayer/numidium.svg?branch=master)](https://travis-ci.org/DarkWiiPlayer/numidium) [![Gem Version](https://badge.fury.io/rb/numidium.svg)](https://badge.fury.io/rb/numidium)
==========================================================================================

Note: Numidium has been completely rebuilt in version 0.6!

Numidium is a Library/Toolbox mainly intended for [TDD](https://en.wikipedia.org/wiki/Test-driven_development). The core principiles of Numidium are
- Simplicity of Implementation: doing more things with less code / classes.
- Simplicity of Use: offering more options in less idioms.
- Flexibility: allowing for more while needing less boilerplate.
- Modularity: a small core implementation and some modules stacked on top of it.
- Freedom of choice: Inversion of control is optional and so are conventions.

There are no `equals` or `is_type` assertions, because there is equally convenient ruby methods that do exactly that. There are, however, a few factory functions that generate more high-level tests. (more like there *will* be tehe~)

TODOs
==========================================================================================

- Write tests in plain ruby -- started
- Write some examples
- Add prefab tests

Using Numidium
==========================================================================================


Results and Reports
-----------------------------------------

Results and Reports are Numidiums way of returning meta-information about a test run.
They have a lot of things in common:

All result and report objects have a `success` property, which is true when the test was successful, false when it wasn't and nil if it isn't a result that can pass or fail. For example, skipped tests count neither as failed nor passed. To make life a bit easier, there's also the methods `failed?` and `passed?` to make life easier.

They also have a `type` property, which stores a symbol describing what type of result they represent.

### Results

They store information about a single test run.

### Reports

Reports are collections of several results and other nested reports. They compile this information into human-readable output.

They always have the type attribute of `:report`

Plain Assertions
-----------------------------------------

For simple test situations, `Numidium::assert` offers an easy mechanism to describe a test. It follows the same syntax as assertions in test blocks:

```
Numidium::assert("foo should return :bar") { foo.call == :bar }
```

but instead of reporting a test result to a report object, it simply returns true or raises an error with the provided message.

Tests
-----------------------------------------

Tests can be created easily, they take a string argument, and either a block or an argument that responds to `:call`. The order of the arguments does not matter.

Within the block passed to the test, the assert method is the preferred way of testing behavior. It accepts a description string and a block. If the block is evaluated to a truthy value, it reports a success, otherwise it reports failure.

The description of the assertion should ideally describe the desired behavior, not what went wrong.

One can also report succes or failure directly with the `fail` and `pass` methods.

```ruby
test_qualified = Numidium::Test.new("Actor should be qualified") do |actor, role|
  assert("Actor and Role should be about the same age") { (actor.age - role.age).abs < 10 }
  assert("Actor should be skilled enough") { actor.skill >= role.required_skill}
end
...
puts test_qualified.run("Gérard Depardieu", "Edmond Dantès")
```

Test descriptions *should* describe the desired behavior, similar to assertions.

### Exceptions

Exceptions in test blocks are caught by run/try and will generate a special kind of result, which counts as neither successful nor failed and has the type `:exception`.

This is to discourage using exceptions as a way to make tests fail. Tests that throw exceptions should not be considered failed, but broken. Behavior that could cause an exception should either be tested earlier or rescued (one of the few instances where `pass` and `fail` could be more useful than assertions).

### Skipping

If a test isn't implemented yet or the feature is not complete or whatever reason you may find, you can skip tests. Skipped tests will appear in reports as skipped and won't count as success *or* failure.

```
Numidium::Test.new "Test my tea" do
  # tea = Tea.new # the tea class doesn't exist yet
  skip "Tea should taste good" { tea.tastes_good? }
end
```

See the block behind skip? Yeah, that gets ignored. But it's not a feature of Numidium; ruby just doesn't give a shit about random blocks normal methods. This being the case though, it is recommended to always write a test block, even if it only contains a *todo* comment.

Okay, you can skip tests manually, that's not all that impressive. There's more though.

```
Numidium::Test.new "Test my tea" do
  given assert("Tea class should exist") { defined? Tea } do
    assert("Tea should be awesome") { Tea::is_awesome? }
    my_tea = Tea.new
    given assert("Tea should have a drink method") { my_tea.respond_to? :drink } do
      assert("Tea.drink should return the tea object") { my_tea.drink == my_tea }
    end
  end
end
```

Okay, what's going on there? When the `Tea` class is not defined, the following tests make no sense and will all raise exceptions anyway. the `given` method executes the following block in a special context where all assertions are skipped and reported as such, but **only** if the condition is not met. In other words `given(condition) { optional tests }`.

`given` blocks can be nested without problem. Note though that once a given block is set to skip, all nested given blocks are no-ops, even if their conditions evaluate to true. The condition blocks of `assert` calls are not evaluated to avoid exceptions, so avoid that. Outside of assertions, exceptions within a `given` block can still trigger the entire test to fail and abort. This is both intended and inavitable anyway.

### Using tests

Tests can be executed in two ways: `run`, which generates a report object and `try`, which only generates a result object.

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
test_animal_fast = Numidium::Test.new("%s should be fast") |animal|
  assert { animal.speed > 20 }
end

test_animal_fast.run(rabbit) #-> this works
test_animal_fast.run(dolphin, :nonsense) #-> this works too
test_animal_fast.run() #-> this fails horribly though
```

Helper Classes
==========================================================================================

Comparator
-----------------------------------------

Given a reference block during its creation, this object copmares the execution blocks to this reference.

```
hundred_Is Numidium::Comparator.new { 100.times { |i| i.to_s } }
hundred_Is.compare { 10.times { puts "PrInTiNg StUfF" } }
```

The result of the `compare` method is the factor by which the new block is slower than the reference; that is, how many times faster the reference block was.

Put even simpler, a result of 1.5 means the compared block took one and a half times as long as the reference.

Examples
===
Here's a short example of a rather pointless test scenario. In this case we want to make sure math still works in ruby.

```ruby
require "lib/numidium"
require "lib/numidium/test"

expr_test =
  Numidium::Test.new "expression %s should equal %i" do |expr, result|
    res = eval(expr)
    assert("%s should equal %i") { res == result }
  end

test_math = Numidium::Test.new "Check if math works" do
  try expr_test, "1 + 1", 2
  test expr_test, "1 + 2", 3
  test expr_test, "1 - 2", -3 # Ooops!
  skip "Do this later"
end

rep = test_math.run

puts rep.tap.join("\n")
puts "-----------------"
puts rep
```

but it seems the programmer made a [last line mistake](https://www.viva64.com/en/b/0260/) in that code.

The output of that code would look somewhat like this:

```
1..4
ok 1 expression 1 + 1 should equal 2
ok 2 1 + 2 should equal 3
not ok 3 1 - 2 should equal -3
ok 4 Do this later # Skip
-----------------
Check if math works
+ expression 1 + 1 should equal 2
  expression 1 + 2 should equal 3
  + 1 + 2 should equal 3
  expression 1 - 2 should equal -3
  - 1 - 2 should equal -3
  ... # stack trace ommitted
~ Do this later
```

Since the test constructs the message from its parameters, the error in the test parameters is reflected in its output, making it easy to spot as a copy-paste mistake.
