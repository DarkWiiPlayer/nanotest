class Numidium
	class BlockEnvironment
		def initialize(opts={})
			@failed=0
			@succeeded=0
			@opts=opts.freeze
			@notify = Numidium.new().method(:notify)
		end
		attr_reader :failed, :succeeded

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
				@notify.(test.first || "Assertion failed", false, location: test.last.source_location) if @opts[:notify]
				if @opts[:abort]
					throw(:numidium_block, test.first)
				else
					@failed+=1
				end
			else
				@succeeded+=1
			end
		end
	end

	def self.block(opts={}, &block)
		opts[:abort] = true unless opts.has_key?(:abort)
		return [
			opts[:message],
			lambda do |*args|
				reason = catch(:numidium_block) do
					block_env = BlockEnvironment.new(opts)
					block_env.instance_eval(&block)

					if block_env.failed == 0 then
						return true
					else
						return false
					end
				end
				return reason || false
			end
		]
	end

	def self.block_test(opts={}, &block)
		opts[:silent] = opts[:notify] unless opts.has_key?(:silent)
		test = new(opts) do
			add(self.class.block(opts, &block))
		end
		test.try(*opts[:args])
	end
end
