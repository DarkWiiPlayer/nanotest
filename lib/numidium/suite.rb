# -- vim: set noexpandtab :miv --
require_relative "test"
require_relative "report"
require_relative "refinements/string_indent"

module Numidium
	@subclasses = []
	@instances  = []
	class Suite
		def initialize(opts={}, &block)
			if not opts.is_a? Hash
				raise ArgumentError, "Argument should be a Hash!"
			end
			@tests = []; @opts = opts
			@description = 
				@opts[:description] ||
				raise(ArgumentError, "No suite description provided")
			if not block
				raise ArgumentError, "Must provide a block!"
			end
			self.instance_exec(&block)
		end

		def test(test, *args)
			@tests << [test, :run, args]
		end

		def try(test, *args)
			@tests << [test, :try, args]
		end

		def run()
			results = []
			@tests.each do |test, method, args|
				results << test.send(method, *args)
			end
			Numidium::Report.new(title: "\n%s\n===============\n")
				.set_description(@description)
				.set_items(results)
		end
	end
end
