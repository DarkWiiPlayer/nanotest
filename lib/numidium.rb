# vim: set noexpandtab list:
require_relative "numidium/version"

class Numidium
	def self.run(opts={}, *args, &block)
		new(opts, &block).run(*args)
	end
	def self.try(*args, &block) run(*args, &block)==0 end

	def initialize(opts={}, &block)
		@tests = []
		@before = []
		@after = []
		@opts = opts
		self.instance_eval(&block) if block
	end

def add(first=nil, *args, &block)
	if block then
		@tests << [first, block]
	elsif first.is_a? self.class then
		@tests << [first.message, ->(*largs) { first.try(*args, *largs) }]
	elsif first.respond_to? :call then
		@tests << [nil, first]
	elsif args.first.respond_to? :call then
		@tests << [first, args.first]
	elsif first.is_a? Array then
		add(*first, &block)
	elsif first.is_a? Hash then
		first.each { |msg,prc| add([msg, prc]) }
	else
		raise ArgumentError,
			"Wrong arguments provided: #{[first.class] + args.map { |e| e.class }}"
	end
	return self
end; alias :define :add; alias :<< :add

	def before(step=nil, &block)
		@before << (block || step || raise(ArgumentError, "Neither block nor lambda provided"))
	end; alias :setup :before

	def after(step=nil, &block)
		@after << (block || step || raise(ArgumentError, "Neither block nor lambda provided"))
	end; alias :cleanup :after

	def run(*args)
		@before.each { |step| step.call(*args) }
		failed = 0
		tests = (opts :random) ? @tests.shuffle : @tests
		tests.each_with_index do |test, i|
			begin
				result = test[1].call(*args)
			rescue Exception => e # because ScriptError doesn't inherit from StandardError
				result =
					"#{test[0]}\nTest threw an exception (#{e.class}):\n" +
					" -> #{e.message}\nBacktrace:\n" +
					"#{e.backtrace.join "\n" }" +
					"\n...this means your test is broken, go fix it!"
			end
			if result and not result.is_a?(String) then
				notify(test[0],true,i) if opts :notify_pass, :verbose
			else
				notify(result || test[0],false,i) if (result or test[0]) and not opts :silent
				failed += 1
				return true if opts :abort_on_fail
				break if opts :break_on_fail
			end
		end
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

	private

	def notify(msg, pass, i=0)
		puts "#{@opts[:line_start]}Test #{pass ? "passed" : "failed"}: #{@opts[:prefix]}#{msg}"
	end
end
class NumidiumTestFailed < StandardError; end
