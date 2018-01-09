Nanotest
============
Nanotest is a minimalistic library for writing test cases in ruby. It was built with test driven development in mind, but tries to make no assumptions about the use case the tests are written for.

One of nanotests simplicity goals is that the entire core implementation fits on my (rotated) screen in the font size I use during development. The main design filosophy is doing as much as possible with as little code and as little documentation as possible. One shouldn't have to spend hours learning a tool that doesn't get any work done by itself, like it's often the case with other testing frameworks that expect the user to learn an entire DSL for something that most of the time isn't even a part of the actual product, but a tool used to ensure its quality and *save time*.

Introcuction
------------

At the core of the library is the Nanotest class; which defines what a test looks like. A nanotest instance is a collection of subtests consisting of a message and a lambda. I will refer to these as *[test] atoms* or *atomic tests*, as they are are the smallest units defined by nanotest.

This is the internal representation of an atom in the Nanotest class:

```ruby
atom = ["one plus one must be two", -> { 1+1==2 }]
```

So, from now on, *atom*: `(message, lambda)`

### Success and Failure

A test fails when the lambda returns a falsey value (`false` or `nil`) or a string containing a more detailed message.

Before implementing any actual functionality, let's first check that the universe still makes sense:

```ruby
world_test = Nanotest.new
world_test.add "One equals one", lambda { return 1 == 1 }
world_test.run
```

As you can see, you add (atomic) tests with the `add` method.

###Adding Tests

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

###Output

If an atom fails with `nil` or `false`, its default message is printed; if it fails with a string, that string is printed instead. For any other return value, the test succeeds.

If no default fail message is provided and the test fails with `nil` or `false`, nothing at all is printed (use this when you want to deal with the output elsewhere)

```ruby
nanotest.run do
  add -> { false } # this outputs nothing
  add "default message", -> { false } # this outputs a default message
  add "default message", -> { "custom message" } # this outputs a custom message
end
```

```ruby
big_test = nanotest.new do
  add (nanotest.new message: "numbers must work" do
    add -> { 1 == 1 }
    add -> { 2 == 2 }
  end)
end
# In this example we don't care wether it's `1` or `2` that fails,
# so we don't output anything in the individual tests.
# The containing test (more on subtests later) takes care of printing the message.
```

```ruby
world_test.add "Magic should work", -> {"magic" == "works"}
world_test.add "Earth should be flat", -> {"earth"=="flat" ? true : "No it's not"}
```
Both of the above tests fail; the first one prints "Magic should work", telling us what doesn't work, but not why. The second test prints "No it's not", letting us know not only what doesn't work, but giving us detailed insight into what exactly failed. Well, except it doesn't. In the end it comes down to the quality of the messages the developers write.

new do... and run do...
------------
To make defining tests on the fly easier, `Nanotest.new` and `Nanotest.run` both accept a block that is evaluated in the context of the new instance. `new` returns said instance, while `run` calls `run` on the new instance and returns its result.

`Nanotest.run` takes the same arguments as `new`, and passes all extra arguments to the `run` instance method.

Arguments
------------
All arguments to the run() method are passed to each individual test. Therefore it is recommended to write lambdas as `-> (*args) {...}` when they are meant to be reusable. You can also use this to write reusable test cases:

```ruby
test_number = Nanotest.new do
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
supertest = Nanotest.new message: "Everything should be fine"
supertest.add "Yes it is", -> { true }
supertest.add world_test
```

When a subtest has a `:message` option set, this string is automatically added as the fail message of the test that is added. Otherwise it is `nil` and output is expected to be handled elsewhere (either by the subtests own tests or further up or manually)

Additional arguments to `add` are passed to the subtest followed by the arguments to the tests `run` method.

```ruby
big_test = Nanotest.new
small_test = Nanotest.new
small_test.add ->(*args) { args == [:add, :run] }
big_test.add small_test, :add
big_test.run(:run)
```

Eval Module
------------
Of course, with only the primitives mentioned above, creating tests for complex projects would still be a lot of work. For that reason Nanotest comes with a few modules that add factory functions for common tests.

```ruby
require "nanotest/eval"
E = Nanotest::Eval
Nanotest.run do
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

`maps` is possibly the most powerful function in the Eval module. It takes an expression and a map aka. hash, and evaluates the function for each pair in the map with the values of the key (which should be an array) as arguments, and fails when the result differs from the corresponding value. As always, an options hash can be passed as third argument.

```ruby
abs = ->(x){x>=0 ? x : -x}
Nanotest.run do
  add Nanotest::Eval::maps
    abs,
    {
      [ 1] => 1
      [-1] => 1
      [ 0] => 0
    },
    message: "Tests lambda to calculate absolute values"
end
```

unless the `:noraise` options is set to a truthy value, `maps` also succeeds of the function throws an error of the class provided as if it was returning it.

```ruby
div -> (x,y) do 
  raise ArgumentError if y==0
  x/y
end
Nanotest.run do
  add Nanotest::Eval::maps
    div,
    {
      [1,1] => 1,
      [1,0] => ArgumentError
    }
  end
end
```

Before/After
------------

Options
------------

Advanced Uses
====================

Arguments and Subtests
------------

As stated above, not repeating oneself is *kind of* an important concept in programming, and subtests serve that purpose (among others). But if you write a test once, there's no real point in running it more than once, specially since the `lambda` object is closed in the context of its creation. So what's the point anyway?

Argumens. The answer is arguments. Imagine the following test:

```ruby
adder = ->(a,b) {a+b}
...
test_adder = Nanotest.new(message: "A lambda should correctly add two numbers") begin
  add "Should correctly add  1 + 1", -> {adder.call( 1,1) ==  2}
  add "Should correctly add  0 + 1", -> {adder.call( 0,1) ==  1}
  add "Should correctly add -1 + 0", -> {adder.call(-1,0) == -1}
end
```

This test only checks a single lambda, and the deterministic nature of the test means it will yield the same results every time we try it. A way to avoid this would be to do the following:

```ruby
...
test_adder_generic = Nanotest.new(message: "A lambda should add two numbers") begin
  add "Should correctly add  1 + 1", ->(arg_adder){arg_adder.call(1,1) ==  2}
  ...
end
...
```

Now we have a NanoTest with three subtests that each take an argument... but where does that argument come from?

```ruby
... # define two adder lambdas
test_adder_generic.run(optimized_adder_function)
test_adder_generic.run(portable_adder_function)
```

Like this; when running a test, any argument to the run method is passed to all the subtests. But the best part comes now:

```ruby
Nanotest.new(message: "Test optimized code") do
  sub test_adder_generic, optimized_adder_function
end
...
# same for portable code
```

The `sub` method passes all aditional arguments after the subtest to the subtests `run` method. This allows reusing a subtest with different arguments, be they algorithms in the form of lambdas, different values, objects, classes, etc. Imagine, for example, writing a generic test that makes sure that a class implements a certain defined interface; it should answer to certain signals, maybe return some specific kinds of values, like version strings matching a certain pattern, etc.
This subtest could then be reused countless times with many different implementations, or even be the main specification of the interface (if it is well enough documented, at least).
