class Nanotest
  def self.version
    return [0, 1, 1]
  end

  def self.run(opts={},&block)
    test = new opts, &block
    test.run
  end

  def initialize(opts={}, &block)
    @tests = []
    @before = [] # setup
    @after = [] # cleanup
    @opts = opts
    self.instance_eval &block if block
  end
  def message
    @opts[:message] or "Unnamed Test"
  end

  def <<(arg)
    case arg.class
    when self.class
      sub arg
    else
      add arg
    end
    return self
  end
  def add(arg, test=nil)
    if arg.is_a? String and test.is_a? Proc then
      @tests << [arg, test]
    elsif arg.is_a? Proc then
      @tests << ["Unnamed test case", arg]
    elsif arg.is_a? Array then
      add Hash[*arg.flatten]
    elsif arg.is_a? Hash then
      arg.each { |key, value| add key, value}
    else
      raise ArgumentError,
        "Wrong arguments provided: [#{arg.class}, #{test.class}]"
    end
    return self
  end

  def before(step)
    @before << step
  end

  def after(step)
    @after << step
  end

  def sub(subtest, *args)
    raise ArgumentError, <<~EOM unless subtest.is_a? self.class
      First argument should be a test object (is #{subtest.class})
    EOM
    add subtest.message, -> (*largs) { subtest.run(*args, *largs) }
  end

  def run(*args)
    @before.each { |step| step.call(*args) }
    all_pass = true
    if opts :random then
      tests = @tests.shuffle
    else
      tests = @tests
    end
    tests.each_with_index do |test, i|
      begin
        result = test[1].call(*args)
      rescue StandardError => e
        result = "#{test[0]}\nTest threw an exception:\n#{e.message}"
      end
      if result and not result.is_a? String then
        notify(test[0],true,i) if opts :notify_pass, :verbose
      else
        notify(result || test[0],false,i) unless opts :silent
        all_pass = false
        return false if opts :abort_on_fail
        break if opts :break_on_fail
      end
    end
    @after.each { |step| step.call(all_pass,*args) }
    return all_pass
  end

  def notify(msg, pass, i=0)
    puts "Test #{pass ? "passed" : "failed"}: #{msg}"
  end

  def opts(*args)
    return args.any? { |arg| @opts[arg] }
  end
end
