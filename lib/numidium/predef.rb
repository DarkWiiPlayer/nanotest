require_relative "test"

module Numidium
  FunctionMappingSingle = Numidium::Test.new "%s is expected to map the keys of %s to its corresponding values" do |subject, map|
    map.each do |arg, value|
      assert("expected %s to map #{arg.inspect} to #{value.inspect}") { subject.call(arg) == value }
    end
  end

  FunctionMappingArray = Numidium::Test.new "%s is expected to map the keys of %s to its corresponding values" do |subject, map|
    map.each do |arg, value|
      raise "expected #{arg} (key in #{map}) to be an array!" unless arg.is_a? Array
      assert("expected %s to map #{arg.inspect} to #{value.inspect}") { subject.call(arg*) == value }
    end
  end
end
