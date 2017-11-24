Nanotest
============
Nanotest is a minimalistic library for writing test cases in ruby. It was built with test driven development in mind, but tries to make no assumptions about the use case the tests are written for.

Introcuction
------------
At the core of the library is the Nanotest class; which defines what a test looks like. A nanotest instance is a collection of subtests consisting of a message and a lambda.

A test fails when the lambda returns a falsey value (`false` or `nil`) or a string containing a more detailed message.

Before doing any actual programming, let's first check that the universe still makes sense:

```ruby
world_test = Nanotest.new "The world should make sense"
world_test.add "One equals one", lambda { return 1 == 1 }
world_test.run
```

If a test case fails with `nil` or `false`, its default message is printed; if it fails with a string, that string is printed instead. For any other return value, the test succeeds.

```ruby
world_test.add "Magic should work", -> {"magic" == "works"}
world_test.add "Earth should be flat", -> {"earth"=="flat" ? true : "No it's not"}
```
Both of the above tests fail; the first one prints "Magic should work", telling us what doesn't work, but not why. The second test prints "No it's not", letting us know not only what doesn't work, but giving us detailed insight into what exactly failed. Well, I guess it ultimately depends on the quality of the messages that the programmer defines.

The add method adds a test case to a nanotest object. It can take several formats of arguments, but they all come down to one or more pairs of a string and a lambda.

```ruby
# The following three calls to add do the same thing
world_test.add [["message", ->{true}], ["message", ->{true}]]
# The above array is flattened to look like the one below
world_test.add ["message", ->{true}, "message", ->{true}]
# The above array is converted into a hash like the one below
world_test.add {"message 1"=>->{true}, "message 2"=>->{true}}
# Add iterates hashes and recursively calls add on each key,value pair
```

As an alternative to the `add` method, Nanotest overloads the `<<` operator, allowing a single argument that is either a message+lambda test, or a subtest (another instance of Nanotest, more on this later) to be added.

```ruby
world_test << ["message", -> {true}]
# This doesn't work though:
# world_test << "message", -> {true}
```

Define and run
------------
The Nanotest class has two useful functions for defining tests on the fly:

`define` creates a new instance, takes a block and runs it in the context of the new object and then returns that instance.

`run` acts the same way, but it calls `run` on the new instance after evaluating the block and returns the result of `run` instead.

Arguments
------------
All arguments to the run() method arepassed to each individual test. Therefore it is recommended to write lambdas as `-> (*args) {...}` when they are meant to be reusable. You can also use this to write reusable test cases:

```ruby
test_number = Nanotest.define do
  add "Larger than 0",
    -> (x, *rest) {x>0 ? true : "Number (#{x}) is <= 0"}
  add "Smaller than 100",
    -> (x, *rest) {x<100 ? true : "Number (#{x}) is >= 100"}
end
test_number.run(5)
test_number.run(8, 10000)
# the aditional argument does no harm because of the `*rest`
```

Subtests
------------

Not repeating oneself is kind of a thing in programming, therefore Nanotest allows adding other test instances as subtests.

```ruby
supertest = Nanotest.new "Everything should be fine"
supertest.add "Yes it is", -> { true }
supertest.sub world_test # These two lines
supertest << world_test  # Are equivalent
```

Eval Module
------------
Of course, with only the primitives mentioned above, creating tests for complex projects would still be a lot of work. For that reason Nanotest comes with a few modules that add factory functions for common tests.

```ruby
require "nanotest/eval"
E = Nanotest::Eval
Nanotest.run do # like define, but runs the test at the end
  add E::equal { return 100 }, "100"
  # Compares the results of two expressions
end
```

Other factory functions in the Eval module are:

```
Nanotest::Eval::Truthy(expr, opts={})
# Fails unless `expr` evaluates to a truthy value
# Valid options:
# * :binding => <binding>
# * :message => string (a custom description of the test)
Nanotest::Eval::Falsey(expr, opts={})
# Fails if `expr` evaluates to a truthy value
Nanotest::Eval::equal(exp1, exp2, opts={})
# Fails unless both expressions evaluate to the same value
Nanotest::Eval::unequal(exp1, exp2, opts={})
# Fails if both expressions evaluate to the same value
Nanotest::Eval::succeeds(expr, opts={})
# Fails if `expr` throws an error
Nanotest::Eval::fails(expr, opts={})
# Fails *unless* `expr` throws an error
Nanotest::eval::maps(expr, table, opts={})
```

`maps` is possibly the most powerful function in the Eval module. It takes an expression and a map (known as hash in ruby-speek), and evaluates the function for each pair in the map with the values of the key (which should be an array) as arguments, and fails when the result differs from the corresponding value.

```ruby
abs = ->(x){x>=0 ? x : -x}
Nanotest.run do
  add Nanotest::Eval::maps
    abs,
    {
      1 => 1
      -1 => 1
      0 => 0
    },
    message: "Tests lambda to calculate absolute values"
end
```

Args Module
------------

Before/After
------------

Options
------------
