require_relative "../lib/numidium"
require_relative "../lib/numidium/syntax"

$test_syntax = Numidium.new(break_on_fail: true, raise: true, prefix: "syntax> ") do

	after -> (success) { puts success==0 && "Syntax class is OK" || nil }

	add("string should pass for valid ruby code") do
		Numidium::Syntax.string("1 + 1")[1].call == true
	end

	add("string should fail for invalid ruby code") do
		Numidium::Syntax.string("1 = 1")[1].call.is_a? String
	end
end
