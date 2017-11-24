require "nanotest/common"

class Nanotest
  module Eval
    def self.run expr, binding, *args
      if expr.is_a? Proc then
        return expr.(*args)
      else
        return eval expr, binding
      end
    end

    def self.truthy(expr, opts={})
      message = opts[:message].to_s + "#{opts[:message] ? "\n" : nil}Expect `#{expr}` to be truthy"
      [
        message,
        lambda do |*args|
          res = run expr, opts[:binding], *args
          !!res || message + ", got #{res}"
        end
      ]
    end

    def self.falsey(expr, opts={})
      message = opts[:message].to_s + "#{opts[:message] ? "\n" : nil}Expect `#{expr}` to be falsey"
      [
        message,
        lambda do |*args|
          res = run expr, opts[:binding], *args
          !res || message + ", got #{res}"
        end
      ]
    end

    def self.equal(exp1, exp2, opts={})
      message = opts[:message] || "`#{exp1}` should equal `#{exp2}`"
      [
        message,
        lambda do |*args|
          res1 = run exp1, opts[:binding], *args
          res2 = run exp2, opts[:binding], *args
          res1==res2 || message + "\nExpected:\n#{res2.inspect}\nGot:\n#{res1.inspect}"
        end,
      ]
    end

    def self.unequal(exp1, exp2, opts={})
      message = opts[:message] || "`#{exp1}` should not equal `#{exp2}`"
      [
        message,
        lambda do |*args|
          res1 = run exp1, opts[:binding], *args
          res2 = run exp2, opts[:binding], *args
          res1 != res2 || message + "\nBoth evaluate to\n#{res1}"
        end,
      ]
    end

    def self.succeeds(expr, opts={})
      message = opts[:message] || "'#{expr}' should succeed without errors"
      [
        message,
        lambda do |*args|
          !Nanotest::Common::raises?(expr, opts[:binding], *args)
        end,
      ]
    end

    def self.fails(expr, opts={})
      message = opts[:message] || "'#{expr}' should fail with an error"
      [
        message,
        lambda do |*args|
          Nanotest::Common::raises?(expr, opts[:binding], *args)
        end ,
      ]
    end

    def self.maps(expr, table, opts={})
      message = opts[:message] || "`#{expr}` should evaluate each key to its corresponding value"
      [
        message,
        lambda do |*_|
          table.each do |args, value|
            result = run(expr, opts[:binding], *args)
            unless result == value
              return message+"\nincorrectly mapped\n#{args}\nto\n#{value}"
            end
          end
          return true
        end
      ]
    end
  end
end
