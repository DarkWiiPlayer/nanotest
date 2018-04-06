class FailedAssertion < Exception; end
def assert(msg)
  raise FailedAssertion, msg unless yield
  puts "Assertion passed: #{msg}"
end

puts "Testing base module"
require_relative "numidium"
puts "\nTesting Result object"
require_relative "result"
puts "\nTesting Numidium::Report"
require_relative "report"
puts "\nTesting Numidium::Stage"
require_relative "stage"
puts "\nTesting Numidium::Test"
require_relative "test"
puts ""
