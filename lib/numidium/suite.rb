# vim: set noexpandtab :miv
require_relative "test"
require_relative "report"

module Numidium
	@subclasses = []
	@instances  = []
	class Suite
		def initialize(opts={}, &block)
			@tests = []; @opts = opts
			@description = 
				@opts[:description] ||
				raise(ArgumentError, "No suite description provided")
			self.instance_exec(&block)
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
	end
end
