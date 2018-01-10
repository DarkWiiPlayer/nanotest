# vim: set noexpandtab:

class Nanotest
  def self.version
    return [0, 2, 0]
  end

  def self.run(opts={},*args,&block)
    test = new opts, &block
    test.run *args
  end

  def initialize(opts={}, &block)
    @tests = []
    @before = []
    @after = []
    @opts = opts
    self.instance_eval &block if block
  end

  def message
    @opts[:message]
  end

  def add(arg, *args)
    if arg.is_a? String and args[0].is_a? Proc then # message, -> lambda
      @tests << [arg, args[0]]
    elsif arg.is_a? self.class then # subtest
      sub = -> (*largs) { arg.run(*args, *largs) == 0 }
      add arg.message && [arg.message, sub] || sub
    elsif arg.is_a? Proc then # -> lambda
      @tests << [(opts :verbose) ? "Unnamed test case" : nil, arg]
    elsif arg.is_a? Array then # [message, -> lambda]
      add Hash[*arg.flatten]
    elsif arg.is_a? Hash then # {message => -> lambda}
      arg.each { |key, value| add key, value }
    else
      raise ArgumentError, "Wrong arguments provided: [#{arg.class}, #{test.class}]"
    end
    return self
  end

  def before(step)
    @before << step
  end

  def after(step)
    @after << step
  end

  def run(*args)
    @before.each { |step| step.call(*args) }
    failed = 0
    tests = (opts :random) ? @tests.shuffle : @tests
    tests.each_with_index do |test, i|
      begin
        result = test[1].call(*args)
      rescue StandardError => e
        result =
          "#{test[0]}\nTest threw an exception (#{e.class}):\n" +
          " -> #{e.message}\nBacktrace:\n" +
          "#{e.backtrace.reverse.join "\n" }" +
          "...this means your test is broken, go fix it!"
      end
      if result and not result.is_a? String then
        notify(test[0],true,i) if opts :notify_pass, :verbose
      else
        notify(result || test[0],false,i) if (result or test[0]) and not opts :silent
        failed += 1
        return true if opts :abort_on_fail
        break if opts :break_on_fail
      end
    end
    @after.each { |step| step.call(failed,*args) }
    raise NanoTestFailed,<<~EOM if opts :raise and failed>0
      #{failed} test#{failed>1 && 's'} did not pass (see message#{ failed>1 ? 's' : nil } above)
    EOM
    return failed
  end

  private

  def notify(msg, pass, i=0)
    puts "#{@opts[:prefix] ? @opts[:prefix].to_s : ""}Test #{pass ? "passed" : "failed"}: #{msg}"
  end

  def opts(*args)
    return args.any? { |arg| @opts[arg] }
  end
end

class NanoTestFailed < StandardError; end
