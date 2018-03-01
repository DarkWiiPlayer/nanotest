# vim: set noexpandtab :miv
require 'fiber'
module Numidium
	class Stage # Provides a fresh environment every time the test is executed
		def initialize(test, args)
			@test = test; @events = []; @args = args.freeze
		end

		def evaluate(play)
			thread = Fiber.new do
				instance_exec(*@args, &play)
			rescue Exception => e
				Fiber.yield(e)
			end
			loop do
				res = thread.resume(*@args)
				if thread.alive?
					@events << res
				else
					break
				end
			end
			return Numidium::Report.new
				.set_description(sprintf @test.description, *@args)
				.set_items(@events)
		end

		def assert(description=nil, &block)
			desc = description ? ": #{description}" : ""
			res = {success: !!block.call}
			if res[:success]
				res[:message] = "Assertion passed" + desc
			else
				res[:message] = "Assertion failed" + desc
			end
			res[:src] = block.source_location
			Fiber.yield(res)
			return res[:success]
		end

		def fail(reason=nil)
			c = caller_locations(1,1).first
			Fiber.yield({
				success: false,
				message: (reason || "Unknown failure condition met"),
				src: [c.path, c.lineno],
			})
		end

		def inspect() "Stage for #{@test}"; end
		alias :to_s :inspect
	end
end
