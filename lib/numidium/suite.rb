# vim: set noexpandtab :miv
require_relative "../numidium"

module Numidium
	class Suite
		def initialize(opts={})
			@steps = []; @opts = opts
		end

	def add(first=nil, *args, &block)
	end; alias :define :add; alias :<< :add

		def before(step=nil, &block)
			@before << (block || step || raise(ArgumentError, "Neither block nor lambda provided"))
		end; alias :setup :before

		def after(step=nil, &block)
			@after << (block || step || raise(ArgumentError, "Neither block nor lambda provided"))
		end; alias :cleanup :after

		def run(*args)
			@before.each { |step| step.call(*args) }
			tests = (opts :random) ? @tests.shuffle : @tests
			failed = tests.inject(0) do |acc, test|
				begin
					result = test[1].call(*args)
				rescue Exception => e # because ScriptError doesn't inherit from StandardError
					result =
						"#{test[0]}\nTest threw an exception (#{e.class}):\n" +
						" -> #{e.message}\nBacktrace:\n" +
						"#{e.backtrace.join "\n" }"
				end
				if result and not result.is_a?(String) then
					notify(test[0],true,i) if opts :notify_pass, :verbose
					acc
				else
					notify((result || test[0]).to_s, false) if (result or test[0]) and not opts :silent
					return true if opts :abort_on_fail
					break if opts :break_on_fail
					acc += 1
				end
			end || 1
			@after.each { |step| step.call(failed,*args) }
			raise NumidiumTestFailed,<<~EOM if opts :raise and failed>0
				#{failed} test#{failed>1 && 's' || nil} did not pass (see message#{ failed>1 ? 's' : nil } above)
			EOM
			return failed
		end
		def try(*args) run(*args)==0 end

		def message() @opts[:message] end

		def opts(*args) args.empty? ? opts.dup.freeze : args.any? { |arg| @opts[arg] } end
		def setop(opts={}) opts.each { |k,v| @opts[k]=v } end

		private # ====================================================================

		def notify(msg, pass, opts={})
			msg = "#{@opts[:line_start]}Test #{pass ? "passed" : "failed"}: #{@opts[:prefix]}#{msg}"
			puts \
				case opts[:location]
					when Array then msg + "\n+-> " + opts[:location].join(":")
					else msg
				end
		end
	end
end
