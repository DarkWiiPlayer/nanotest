require_relative "../lib/numidium/test"

assert("Numidium::Test should be defined") { defined? Numidium::Test }

assert "Creating a test should require a block" do
  Numidium::Test.new "Hello World"
  false
rescue
  true
end

assert "Creating a test should require a message" do
  Numidium::Test.new do
    fail "'Cuz reasons"
  end
  false
rescue
  true
end

assert "Tests shouldn't run when created" do
  var = 1
  Numidium::Test.new "Witchcraft should work!" do
    var = 2
    assert { "Witchcraft" == "Works" }
  end
  var == 1
end

[:run, :try].each do |method|
  assert "Test should respond to #{method.to_s}" do
    Numidium::Test.new(""){}.respond_to? method
  end
end

assert "run should return a Report object" do
  Numidium::Test.new(""){}.run.is_a? Numidium::Report
end

assert "try should return a Result object" do
  Numidium::Test.new(""){}.try.is_a? Numidium::Result
end
