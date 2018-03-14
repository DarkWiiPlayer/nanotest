require_relative "../lib/numidium/result"

assert("Numidium::Result should be defined") { defined? Numidium::Result }

subject = Numidium::Result.new("Success!", true)
assert("Results should have an origin") { subject.origin }
assert("Results should have a to_s method that returns a string") do
  subject.to_s.is_a? String and not subject.to_s.empty?
end
assert("Results should have a tap method that returns a string") do
  subject.tap(1).is_a? String and not subject.tap(1).empty?
end
assert("Delegate should make the origin array shorter") do
  len = subject.origin.length
  subject.delegate.origin.length == len-1
end

assert("Successful results should report success") { subject.success }
assert("Successful results tap string should be correct") do
  subject.tap(3).match? /^ok\s+3/
end

subject = Numidium::Result.new("Failure!", false)
assert("Unsuccessful results should report failure") { not subject.success }
assert("Unsuccessful results tap string should be correct") do
  subject.tap(3).match? /^not ok\s+3/
end

subject = Numidium::Result.new(Numidium::Failed.new("U Sux!"))
assert("Exception results should report failure") { not subject.success }
