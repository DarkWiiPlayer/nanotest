require_relative "../lib/numidium"
require_relative "../lib/numidium/suite"
require_relative "../lib/numidium/eval"

$test_suite = Numidium.new(break_on_fail: true, raise: true, prefix: "suite> ") do

	after -> (success) { puts success==0 && "Test Suite module is OK" || nil }

  add(Numidium::Eval.fails(exception: ScriptError,
                           message: "Suite class should not have the run method") do
    Numidium::Suite.run
  end)

  add(Numidium::Eval.succeeds(exception: ScriptError,
                              message: "Subclasses should have the run method") do
    Class.new(Numidium::Suite).run
  end)

  add("run should run all subtests") do
    suite = Class.new(Numidium::Suite) do
      new do
        add { false }
        add { false }
        add { false }
      end
    end
    suite.run == 3
  end

  add("try should succeed if all subtests succeed") do
    suite = Class.new(Numidium::Suite) do
      new do
        add { true }
      end
      new do
        add { true }
      end
    end
    suite.try
  end

  add("try should fail if any subtest fails") do
    suite = Class.new(Numidium::Suite) do
      new do
        add { false }
      end
      new do
        add { true }
      end
    end
    !suite.try
  end

  add("arguments to run should be passed") do
    suite = Class.new(Numidium::Suite) do
      new do
        add ->(arg) { arg }
      end
    end
    suite.try(true) && !suite.try(false)
  end

  add("params should be passed as arguments") do
    suite = Class.new(Numidium::Suite) do
      @params << true
      new do
        add ->(a,b) { true }
      end
    end
    suite.try(true)
  end

  add("params should be passed before arguments") do
    suite = Class.new(Numidium::Suite) do
      @params << :param
      new do
        add ->(first, second) { first==:param && second==:arg }
      end
    end
    suite.try(:arg)
  end

  add("params should be immutably accessible from outside") do
    suite = Class.new(Numidium::Suite) do
      new do
        add -> (*args) { args == [] }
      end
    end
    suite.params.frozen?
  end

  add("tests within tests") do
    suite = Class.new(Numidium::Suite) do
      new do
        add { false }
      end
      Class.new(self) do
        new do
          add { false }
        end
      end
    end
    suite.run == 2
  end

  add("tests within tests within tests") do
    suite = Class.new(Numidium::Suite) do
      new do
        add { false }
      end
      Class.new(self) do
        new do
          add { false }
        end
        Class.new(self) do
          new do
            add { false }
          end
        end
      end
    end
    suite.run == 3
  end

  add("suite.run should only run child suites") do
    top = Class.new(Numidium::Suite) do
      new do
        add { false }
      end
    end
    mid = Class.new(top) do
      new do
        add { true }
      end
      Class.new(self) do
        new do
          add { true }
        end
      end
    end

    mid.run == 0
  end
end
