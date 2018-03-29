require_relative "../lib/numidium"
require_relative "../lib/numidium/test"

class Foo
  def bar() true; end
end

res = Numidium::Test.new("%s should bar", lambda do |subject|
  inst = subject.new
  given assert("%s should respond to bar") { inst.respond_to? :bar } do
    assert("%s.bar should return true") { subject.new.bar }
  end
  given assert("%s should respond to foo") { inst.respond_to? :foo } do
    assert("%s.foo should return true") { subject.new.foo }
  end
end).run(Foo)

puts res

puts res.tap.join "\n"
