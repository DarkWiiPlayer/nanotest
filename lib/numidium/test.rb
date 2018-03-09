# vim: set noexpandtab :miv
require_relative 'report'
require_relative 'stage'

module Numidium
	class Test
		attr_reader :description

		def self.assert(*args, &block)
			new do
				assert(*args, &block)
			end
		end

		def initialize(*args, &block)
			args.flatten!
			if (idx=args.find_index{|arg| arg.is_a? String}) then
				@description = args[idx]
			else
				error "creating test without a description"
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

		def report
			Numidium::Report.new(title: "-- %s --")
		end

		def execute(*args)
			stage = Numidium::Stage.new self, args
			stage.evaluate @method
		end

		def run(*args)
			report
				.set_description(sprintf(@description, *args))
				.set_items(execute(*args))
		end

		def try(*args)
			res = run(*args).success
			Result.new(sprintf(@description, *args), res).delegate
		end

		def to_s() @description and "#{super}: #{@description}" or super; end
	end
end
