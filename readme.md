Numidium [![Build Status](https://travis-ci.org/DarkWiiPlayer/numidium.svg?branch=master)](https://travis-ci.org/DarkWiiPlayer/numidium) [![Gem Version](https://badge.fury.io/rb/numidium.svg)](https://badge.fury.io/rb/numidium)
============

Concepts
==========

Assertions & Failure Conditions
----------

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
----------

Numidium tests represent smaller features and functionalities. They can take parameters, which is recommended in all but the smallest ad-hoc tests, and take a string argument and either a block or an argument that responds to the :call method.

```ruby
test_qualified = Nanotest::Test.new("Actor should be qualified") do |actor, role|
  assert("Actor and Role should be about the same age") { (actor.age - role.age).abs < 10 }
  assert("Actor should be skilled enough") { actor.skill >= role.required_skill}
end
...
test_qualified.run("Gérard Depardieu", "Edmond Dantès")
```

Before passing the description to the report object it feeds it througn sprintf with the arguments of run(). Since sprintf fails when not enough arguments are provided for a string, it is recommended to only do this in combination with lambdas:

```ruby
test_animal_fast = Nanotest::Test.new("%s should be fast") |animal|
  assert { animal.speed > 20 }
end

test_animal_fast.run(rabbit) #-> this works
test_animal_fast.run(dolphin, :nonsense) #-> this works too
test_animal_fast.run() #-> this fails horribly though
```
