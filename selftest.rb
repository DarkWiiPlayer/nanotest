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
  passes.run(Nanotest.new(silent: true){ add "Passes",->{ true } }),
  fails.run(Nanotest.new(silent: true){ add "Fails",->{ false } }),
].any? { |e| !e }

Nanotest.run break_on_fail: true do
  subtest = Nanotest.new
  subtest.add -> { 1 + 1 == 2 }
  subtest.add -> { 2 + 2 == 4 }
  sub subtest
end

puts "All seems good :)"
