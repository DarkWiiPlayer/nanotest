# vim: set noexpandtab :miv
require_relative "test"
require_relative "report"

module Numidium
	class Suite
		def initialize(opts={}, &block)
			@tests = []; @opts = opts
			@description = 
				@opts[:description] ||
				raise(ArgumentError, "No suite description provided")
			self.instance_exec &block
		end

		def add(test, *args)
			@tests << [test, args]
		end

		def run()
			reports = []
			@tests.each do |test, args|
				reports << test.run(*args)
			end
			Numidium::Report.new(title: "== %s ==")
				.set_description(@description)
				.set_items(reports)
		end

		def self.inherited(subclass)
			if @subclasses << subclass
				subclass.instance_eval do
					@subclasses = []
					@instances  = []
					@params     = []
				end
			end
		end
	end
end

if $0 == __FILE__ then
	writer_test_awesome = Numidium::Test.new "%s should be awesome" do |writer|
		fail("#{writer} is not awesome!") if writer.length > 7
	end
	writer_test = Numidium::Test.new "%s should be qualified" do |writer|
		assert("#{writer} should exist") { writer }
		assert("#{writer} should be talented") { writer.to_s.length > 3 }
		test writer_test_awesome, writer
	end

	actor_suite = Numidium::Suite.new description: "All writers should be qualified" do
		add writer_test, "Shakespeare"
		add writer_test, "Goethe"
		add writer_test, "Poe"
		add writer_test, "Herbert"
	end

	puts actor_suite.run
end
