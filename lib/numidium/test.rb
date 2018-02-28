# vim: set noexpandtab :miv
require 'benchmark'

module Numidium
	attr_reader :description
	class Test
		def initialize(*args, &block)
			args.flatten!
			if (idx=args.find_index{|arg| arg.is_a? String}) then
				@description = args[idx]
			end
			@method = 
				if block then
					block
				else
					if idx = args.find_index{|arg| arg.respond_to? :call} then
						args[idx]
					else
						raise ArgumentError, "Can't define a test that does nothing :|"
					end
				end
		end

		def run(*args)
			result = Numidium::Result.new @description, self
			result.evaluate @method, *args
			result
		end

		def try(*args)
			run(*args).success
		end
		def to_s() @description and "#{super}: #{@description}" or super; end
	end

	class Result
		attr_reader :success, :reason, :time, :exception
		def initialize(desc, test)
			@description = desc; @test = test
		end
		def evaluate(method, *args)
			res = nil
			@time = Benchmark.measure do
				res = instance_exec(*args, &method)
			rescue Exception => e
				res = e
			end
			if res == true then
				@success = true
			elsif res.is_a? Exception then
				@success   = false
				@reason    = "The test has raised an exception. (#{res.class})"
				@exception = res
			elsif !res then
				@success = false
				@reason  = @description
			else
				@success = false
				@reason  = res.to_s
			end
		end

		def to_s() "#{super} for #{@test}"; end
	end
end

if $0 == __FILE__ then
	test = Numidium::Test.new("Argument should not be nil", -> (arg) { !arg.nil? })
	puts test.run().success
	puts test.run().exception
end
