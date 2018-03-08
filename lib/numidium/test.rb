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
			result = Numidium::Stage.new self, args
			result.evaluate @method
		end

		def try(*args)
			run(*args).success
		end
		def to_s() @description and "#{super}: #{@description}" or super; end
	end
end
