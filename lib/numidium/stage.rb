# vim: set noexpandtab :miv
require_relative "result"
require 'fiber'
module Numidium
	class Stage # Provides a fresh environment every time the test is executed
		attr_reader :test
		def success
			if not @success.nil?
				@success
			else
				raise "Cannot inquire the success of an unused stage"
			end
		end
		def events
			if not @events.nil?
				@events
			else
				raise "Cannot inquire the events of an unused stage"
			end
		end

		def initialize(test, args)
			@test = test; @args = args.freeze
		end

		def evaluate(play)
			@events = []
			@success = []
			thread = Fiber.new do
				instance_exec(*@args, &play)
			rescue Exception => e
				Fiber.yield(Result.new(e))
			end

			loop do
				res = thread.resume(*@args)
				if thread.alive?
					@events << res
				else
					break
				end
			end
			return @events
		end

		def assert(description=nil, &block)
			desc = description ? ": #{description}" : ""
			res = !!block.call
			Fiber.yield Result(if res
				res[:message] = "Assertion passed" + desc
			else
				res[:message] = "Assertion failed" + desc
			end, res).delegate
			@success &&= res
			return res
		end

		def fail(reason=nil)
			c = caller_locations(1,1).first
			Fiber.yield(Result(reason).delegate)
			@success = false
		end

		def test(test, *args)
			res = test.run(*args)
			Fiber.yield(res)
			@success &&= res.success
			res.success
		end

		def try(test, *args)
			res = test.try(*args)
			Fiber.yield(res)
			@success &&= res.success
			res.success
		end

		def inspect() "Stage for #{@test}"; end
		alias :to_s :inspect
	end
end
