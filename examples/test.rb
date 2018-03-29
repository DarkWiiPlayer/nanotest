require_relative "../lib/numidium"
require_relative "../lib/numidium/test"

class Foo
  def bar() true; end
end

puts Numidium::Test.new("%s should bar", lambda do |subject|
  assert("%s should respond to bar") { subject.new.respond_to? :bar }
  assert("%s.bar should return true") { subject.new.bar }
end).run(Foo).to_s
