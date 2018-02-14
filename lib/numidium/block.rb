class Numidium
	class BlockEnvironment
		def assert(*args, &block)
			args = args[0] if args[0].is_a?(Array)
			test = 
			if block then
				[args[0], block]
			elsif args[0].respond_to?(:call) then
				[args[1], args[0]]
			elsif args[1].respond_to?(:call) then
				[args[0], args[1]]
			else
				raise ArgumentError, "Wrong arguments provided: [#{args.map { |e| e.class }}]"
			end

			if !test[1].call then
				throw(:numidium_block, test[0])
			end
		end
	end

	def self.block(msg="", &block)
		return [
			msg,
			lambda do |*args|
				reason = catch(:numidium_block) do
					BlockEnvironment.new.instance_eval(&block)
					return true
				end
				return reason || false
			end
		]
	end

	def self.block_test(message=nil, *args, &block)
		run(*args) do
			add(self.class.block(message, &block))
		end
	end
end
