Nanotest ![](https://travis-ci.org/DarkWiiPlayer/nanotest.svg?branch=master)
============
Nanotest is a minimalistic library for writing test cases in ruby. It was built with test driven development in mind, but tries to make no assumptions about the use case the tests are written for.

One of nanotests simplicity goals is that the entire core implementation fits on my (1080x1920px) screen in the font size I use during development. The main design filosophy is doing as much as possible with as little code and as little documentation as possible. One shouldn't have to spend hours learning a tool that doesn't get any work done by itself but only serves to ensure quality and *save time*.

Introcuction
------------

At the core of the library is the Nanotest class which defines what a test looks like. In a more abstract context, I refer to this as the nanotest *core*. A nanotest instance is a collection of subtests consisting of a message and a lambda. I will refer to these as *[test] atoms* or *atomic tests*, as they are are the smallest units defined by nanotest.

Internally, *atoms* are stored like this:

```ruby
["one plus one must be two", -> { 1+1==2 }]
```

### Adding Tests

The add method adds a test case to a nanotest object. It can take several formats of arguments, but they all come down to one or more pairs of a string and a lambda. The main way to add a subtest is this though:

```ruby
world_test = Nanotest.new
world_test.add("description of the test") { something == something_else }
```

The string argument describes the meaning of the test, and would usually look something like this *"divide_numbers should raise ArgumentError when divisor is 0"*. The block defines how the described behavior is to be tested and should return a boolean in most cases (more on this in the next section). There are a few other ways to add tests which aren't as much meant to be used literally, but when working with factory functions that generate complex tests from a few parameters like the `Nanotest::Eval` module.

```ruby
# The following three calls to add do the same thing
world_test.add [["message", ->{true}], ["message", ->{true}]]
# The above array is flattened to look like the one below
world_test.add ["message", ->{true}, "message", ->{true}]
# The above array is converted into a hash like the one below
world_test.add {"message 1"=>->{true}, "message 2"=>->{true}}
# Add iterates hashes and recursively calls add on each key,value pair
```

Note though that passing the test code as a lambda leads to some differences. These differences are very much wanted and consist in the following:

* Lambdas check the number of arguments just like a method does; too few or too many and they will throw an error.
* Lambdas can use the `return` statement to return from any place within the block, allowing for more complex logic.

If your test needs to make use of either of those feature, it's a hint that you should consider (not necessarily do) exporting the code someplace else.

### Success and Failure

A test fails when the expression returns a falsey value (`false` or `nil`) or a string containing a more detailed message.

Any other value means the test will fail as of the current implementation, but it is not garanteed that future versions will keep this behavior. The use of `true` is strongly encouraged as it is the only truthy value that will most likely always be treated as a success value.

If a test fails to rescue an error, it automatically fails, and nanotest will tell you about it. Such a test is considered *broken* because it did not deal with the exception, and presumably not expect it either. This suggests either that the test itself needs fixing, or, more likely, that some other test needs to be run first.

Normally tests should deal with __expected__ exceptions internally and fail (or succeed) when they are detected. Keep in mind though that tests should react to as few exceptions as possible, to avoid mistaking a broken test for a failing one. The Eval module provides some useful helper functions for this.

### Output

If an atom fails with `nil` or `false`, its default message is printed; if it fails with a string, that string is printed instead.

```ruby
nanotest.run do
	add("default message") { false } # this outputs a default message
	add("default message") { "custom message" } # this outputs a custom message
	add { false } # this outputs nothing
end
```

If no default fail message is provided and the test fails with `nil` or `false`, nothing at all is printed (use this when you want to deal with the output elsewhere).

```ruby
big_test = nanotest.new do
	add (nanotest.new message: "numbers must work" do
		add { 1 == 1 }
		add { 2 == 2 }
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

Options
------------

Nanotest#new can take an optional hash of named parameters. Here's a list of the possible parameters:

* verbose: boolean # More output, tells you about passing tests as well, etc.
* notify_pass: boolean # Also informs you of passing tests
* silent: boolean # No output at all
* break_on_fail: boolean # Breaks after the first test has failed, runs after-actions
* abort_on_fail: boolean # Aborts after the first test has failed, skips after-actions
* raise: boolean # Raises a NanoTestFailed exception when any test has failed (combine with break_on_fail to raise instantly)
* random: boolean # shuffles the order of the tests

Options can be changed after creating a test with the `setop` method in the same way:

```ruby
test = Nanotest.new(raise: true)
test.setop(raise: false)
```

new do... and run do...
------------
To make defining tests on the fly easier, `Nanotest.new` and `Nanotest.run` both accept a block that is evaluated in the context of the new instance. `new` returns said instance, while `run` calls `run` on the new instance and returns its result.

```ruby
Nanotest.run do
	add { true }
	add { 1+1==2 }
end # Runs automatically and succeeds
```

`Nanotest.run` takes the same arguments as `new`, and passes all extra arguments to the `run` instance method.

Try
------------
Try works pretty much like run, except that it returns `true` when all tests succeed, that is, the result of `run` is 0, and `false` otherwise

Arguments
------------
All arguments to the run() method are passed to each individual test. Therefore it is recommended to write lambda test expressions as `-> (*args) {...}` when they are meant to ignore possible additional arguments for the sake of reusability. In most cases inline test expressions should be passed as a block, so aditional arguments would just be ignored.

```ruby
# Don't do this:
test_number = Nanotest.new do
	add "Larger than 0",
		-> (x, *rest) {x>0 ? true : "Number (#{x}) is <= 0"}
	add "Smaller than 100",
		-> (x, *rest) {x<100 ? true : "Number (#{x}) is >= 100"}
# Do this instead:
	add "Odd" { |x| x%2==1 }
end
test_number.run(5)
test_number.run(8, 10000)
```

Subtests
------------

Not repeating oneself is kind of a thing in programming, therefore Nanotest allows adding other test instances as subtests.

```ruby
supertest = Nanotest.new(message: "Everything should be fine")
supertest.add("Yes it is") { true }
supertest.add(world_test)
```

When a subtest has a `:message` option set, this string is automatically added as the fail message of the test that is added. Otherwise it is `nil` and output is expected to be handled elsewhere (either by the subtests own tests or further up or manually)

Additional arguments to `add` are passed to the subtest followed by the arguments to the tests `run` method.

```ruby
big_test = Nanotest.new
small_test = Nanotest.new
small_test.add { args == [:add, :run] }
big_test.add(small_test, :add) # passed first
big_test.run(:run) # passed second
```

Eval Module
------------
Of course, with only the primitives mentioned above, creating tests for complex projects would still be a lot of work. For that reason Nanotest comes with useful module that provides factory functions for building more complex tests with less code.

```ruby
require "nanotest/eval"
Nanotest.run do
	add Nanotest::Eval::equal(->{ return 100 }, "100")
	# Compares the results of two expressions
end
```

All of the factories in the eval module accept an optional hash of named parameters. They usually have three ways of passing expressions: Lambdas, Strings and Blocks. When the expression is passed as a lambda argument, it is evaluated as is. If it is a string, the string will be evaluated in the current binding, unless a different binding is explicitly provided by the `:binding` option. When a block is provided to the function, that is used instead (and takes precedence over any provided lambda or string), and evaluated the same way as if it were a lambda. Note that detached methods can also be passed as if they were lambdas, and will be properly evaluated in the context of their instance, so there's no need to write a block that wraps an instance method; in fact, this is strongly discouraged as it reduces reusability of the code.

They all share the `:message` and `:binding` option, with the first being used to override the default fail message and the second to provide a binding in case the expression to evaluate is a string. Factories that evaluate more than one expression can take both a single binding or an array of bindings.

They also accept a `:name` option, or in case they have more than one subject, `:name_1`, `:name_2`, ... `:name_n`. This will improve the quality of the output as the test will know what to call the subjects.

Here are all the functions that are available thus far:

`truthy` evaluates a given block or expression and returns `true` if it evaluated to a truthy value and `false` otherwise

```ruby
add Nanotest::Eval::truthy { true }
add Nanotest::Eval::truthy(message: "Truth shall be truthy") { true }
add Nanotest::Eval::truthy(-> { true }, message: "Truth shall be truthy")
add Nanotest::Eval::truthy("true", binding: some_binding)
```

`falsey` works like `truthy`, but does the opposite

`equal` and `unequal` both evaluate two expressions or blocks and return wether they are equal or unequal respectively. If an array of bindings is provided, its first and last elements are used. These two are special in that they don't accept a block as argument, as they need two expressions to compare and one would have to be passed as an argument anyway.

```ruby
add Nanotest::Eval::equal(->{20}, ->{10+10})
add Nanotest::Eval::equal("20", "10+10", binding: [binding, binding], message: "math should work")
```

`succeeds` takes a block/expression and optionally an exception class (passed as the `:exception` option, default is `StandardError`), evaluates the expression and returns true if nothing is raised or false if the expected expression is raised. Other exceptions are not rescued and left to the nanotest core to deal with.

```ruby
add Nanotest::Eval::succeeds { 20 + 20 }

# This test returns `false`; it fails
add Nanotest::Eval::succeeds(exception: ArgumentError) { raise ArgumentError }

add Nanotest::Eval::succeeds(   # This test doesn't rescue anything
	-> { raise StandardError },   # the StandardError should be dealt
	exception: ArgumentError		  # higher up, most likely in the
)                               # Nanotest#run method if not sooner
```

`fails` takes a block/expression and an optional exception class, evaluates it, and only succeeds if it raises an exception of the expected class. Other exceptions are not rescued and if nothing is raised it returns false.

```ruby
add Nanotest::Eval::fails -> { raise "an error" }

# This test succeeds, it raises the expected exception
add Nanotest::Eval::fails(exception: ArgumentError) { raise ArgumentError }

add Nanotest::Eval::fails( # This test breaks, it raises an unexpected exception
	-> { raise ArgumentError },
	exception: RuntimeError
)
```

`maps` is possibly the most powerful function in the Eval module. It takes an expression and a map (aka. hash), and evaluates the function for each pair in the map with the values of the key (which should be an array\*) as arguments, and fails when the result differs from the corresponding value.

If the `:split` option is set, `maps` will return an array of tests, one for each arguments-result pair, instead of a single test that iterates them all in a loop. This is useful when you want all tests to be executed, even if a previous one failed.

\* Note that the argument (key in the hash) doesn't need to be an array; everything other than an array will be passed as a single argument. Just be sure not to get confused when passing an array as single argument; in this case the array needs to be itself inside an array, or its elements will be passed as single arguments.

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
class Klass
	def divide(x,y)
		raise ArgumentError if y==0
		x/y
	end
end
Nanotest.run do
	add Nanotest::Eval::maps
		Klass.new.method(:divide),
		{
			[1,1] => 1,
			[1,0] => ArgumentError
		}
	end
end
```

Before/After
------------

For setup/cleanup and output you can add before- and after-actions.

Add them with the `before` and `after` methods (aliased as `setup` and `cleanup`, if you prefer that), passing a block.

This block will receive all arguments to the `run` method, and in the case of `after`, the number of failed subtests before that.

```ruby
Nanotest.run(:some, :random, :arguments) do
	after { puts "This happens at the end" }
	after { |success| puts "The tests were #{success==0? "successful" : "unsuccessful"}." }
	before { puts "This happens first" }
	before { |*args_to_run| puts "arguments: #{args_to_run}" }

	add { puts "some test"; return true }
end
```

You can also pass a Proc or a Lambda to the `before` and `after` methods. This can be useful for moving more complex output logic out of the test logic or reusing code when various tests should have similar output or setup/cleanup steps.

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
	add("Should correctly add  1 + 1") {adder.call( 1,1) ==	2}
	add("Should correctly add  0 + 1") {adder.call( 0,1) ==	1}
	add("Should correctly add -1 + 0") {adder.call(-1,0) == -1}
end
```

This test only checks a single lambda, and the deterministic nature of the test means it will yield the same results every time we try it. A way to avoid this would be to do the following:

```ruby
...
test_adder_generic = Nanotest.new(message: "A lambda should add two numbers") begin
	add("Should correctly add  1 + 1") { |arg_adder| arg_adder.call(1,1) ==  2 }
	... # the other 2 tests
end
...
```

Maybe at this point it would be worth switching to lambdas because that way ruby makes sure the right number of arguments is passed to the test:

```ruby
...
	add("Should correctly add  1 + 1", -> (arg_adder) { arg_adder.call(1,1) ==  2 })
...
```

Now we have a NanoTest with three subtests that each take an argument... but where does that argument come from? Let's assume we have some generic ruby code and some optimized code that targets a specific platform and is written in C. Both of them should act the same way and differ only in speed and portability.

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

This could be further abstracted by writing a single test and passing it first a module containing the platform-optimized methods and then another one containing the portable counterparts. The sky is the limit, but be sure to always keep a sane level of abstraction depending on the scope of the project. If you're only going to test two functions that add stuff, the first version might just be the quickest to write and can still be improved alter on if needed.
