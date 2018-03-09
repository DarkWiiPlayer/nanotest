# vim: set noexpandtab :miv

=begin Drawings ♥ {{{

	┌──────────────────────────────────────────┐
	│ Stage                                    │
	├──────────────────────────────────────────┤
	│ + evaluate(proc-like*): array            │
	│ - assert(reason:string, block): boolean  │
	│ - fail(reason: string): nil              │
	│ - test(:Test): boolean                   │
	│ - try(:Test): boolean                    │
	├──────────────────────────────────────────┤
	│ + test: Test                             │
	│ + success: boolean                       │
	│ + events: array                          │
	└────────────────────┬─────────────────────┘
											 │
				┌──────────────┴───────────────┐
				│ *proc-like means any object  │
				│ that responds to :call       │
				└──────────────────────────────┘

=end }}}

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

		def inspect() "Stage for #{@test}"; end
		alias :to_s :inspect

		private

		def assert(description=nil, &block)
			description ||= "Assertion failed"
			res = !!block.call
			Fiber.yield Result.new(description, res).delegate
			@success &&= res
			return res
		end

		def fail(reason=nil)
			reason ||= "Test failed"
			c = caller_locations(1,1).first
			Fiber.yield(Result.new(reason).delegate)
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
	end
end
