require_relative "../lib/numidium"
require_relative "../lib/numidium/test"

expr_test =
  Numidium::Test.new "expression %s should equal %i" do |expr, result|
    res = eval(expr)
    assert("%s should equal %i") { res == result }
  end

test_math = Numidium::Test.new "Check if math works" do
  try expr_test, "1 + 1", 2
  test expr_test, "1 + 2", 3
  test expr_test, "1 - 2", -3 # Ooops!
  skip "Do this later"
end

rep = test_math.run

puts rep.tap.join("\n")
puts "-----------------"
puts rep
