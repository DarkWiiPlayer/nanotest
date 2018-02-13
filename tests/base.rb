# vim: set noexpandtab:

class FakeTest
def run(*_)

#=== Create a pseudo-test-object ================================
if [ # TODO: Make this into a test module
	system("ruby -wc lib/numidium.rb"),
	system("ruby -wc lib/numidium/eval.rb"),
].any? { |e| !e } then
	raise "Some of the ruby files aren't okay :|"
end

require_relative "../lib/numidium"

raise "Something very basic is broken :(" if [
	Numidium.run(silent: true){ add -> { true } } <1,
	Numidium.run(silent: true){ add -> { "Witchcraft" == "Works" } } >0,
].any? { |e| !e }

raise "Numidium can't count :(" unless Numidium.run(silent: true) {
	7.times {
		add -> { false }
	}
} == 7

begin
	raise NumidiumTestFailed, "Broken tests aren't counted as failed" if (Numidium.run silent: true do
		add -> { raise "an error" }
	end) != 1
rescue RuntimeError => e
	raise "Numidium doesn't catch exceptions"
end
#================================================================

end
end

$test_base = FakeTest.new
