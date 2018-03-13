require_relative "../lib/numidium/report"

class FailedAssertion < Exception; end
def assert(msg)
  raise FailedAssertion, msg unless yield
  puts "Assertion passed: #{msg}"
end

assert("Numidium::Result should be defined") { defined? Numidium::Report }

subject = Numidium::Report.new

assert("New report should have no success state") { subject.success.nil? }
