require_relative "lib/numidium"
require_relative "lib/numidium/suite"

expr_test =
  Numidium::Test.new "expression %s should equal %i" do |expr, result|
    res = eval(expr)
    assert("expression %s should equal %i") { res == result }
  end

test_suite_math = Numidium::Suite.new description: "Check if math works" do
  try expr_test, "1 + 1", 2
  try expr_test, "1 + 2", 3
  try expr_test, "1 - 2", -3 # Ooops!
end

rep = test_suite_math.run

puts rep.tap.join("\n")
puts "-----------------"
puts rep
