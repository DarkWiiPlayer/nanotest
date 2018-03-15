require_relative "../lib/numidium"

require_relative "../lib/numidium/result"
require_relative "../lib/numidium/report"

assert("Numidium::Result should be defined") { defined? Numidium::Report }

assert("New report should have no success state") do
  Numidium::Report.new.success.nil?
end

assert("Failed reports should have a success state of `false` (not `nil`)") do
  Numidium::Report.new.set_items([
    Numidium::Result.new("*poke*", false)
  ]).success == false
end

assert("Successful reports should have a success state of `true`") do
  Numidium::Report.new.set_items([
    Numidium::Result.new("*poke*", true)
  ]).success == true
end

assert("Reports should fail if a single result has failed") do
  Numidium::Report.new.set_items([
    Numidium::Result.new("the world should be round", true),
    Numidium::Result.new("the world should be flat", false),
    Numidium::Result.new("the world needs yet another testing framework", true)
  ]).success == false
end

# First create some results
results = [
  Numidium::Result.new("Stuff was tested", true),
  Numidium::Result.new("Stuff succeeded", true),
  Numidium::Result.new("Stuff should Work", true)
]

subject = Numidium::Report.new

assert("set_items should return the object itself") do
  subject.set_items(results) == subject
end

assert("set_description should return the object itself") do
  subject.set_description("Some test report") == subject
end

assert("Report should have success-state after adding elements") do
  not subject.success.nil?
end

assert("origin should always return [nil] to ducktype Numidium::Result") do
  subject.origin == [nil]
end

assert("to_s should return a String") do
  subject.to_s.is_a? String
end

assert("to_a should return an Array") do
  subject.to_a.is_a? Array
end

assert "num_failed should count failed results" do
  Numidium::Report.new.set_items([
    Numidium::Result.new("", true),
    Numidium::Result.new("", false),
  ]).num_failed == 1
end

assert "num_failed should only count explicitly failed results" do
  Numidium::Report.new.set_items([
    Numidium::Result.new("", :pass),
    Numidium::Result.new("", :success),
    Numidium::Result.new("", true),
  ]).num_failed == 0
end
