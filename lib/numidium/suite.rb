require_relative "../numidium"

class Numidium
  class Suite < Numidium
    def self.inherited(subclass)
      subclass.instance_eval do
        @subclasses = []
        @instances  = []
      end
      def subclass.inherited(subclass)
        @subclasses << subclass
        subclass.instance_eval do
          @subclasses = []
          @instances  = []
        end
      end
      def subclass.run
        acc = 0
        acc = @subclasses.inject(acc) { |acc, sub| acc + sub.run }
        acc = @instances.inject(acc) { |acc, obj| acc + obj.run }
      end
      def subclass.try
        acc = true
        acc = @subclasses.inject(acc) { |acc, sub| acc & sub.try }
        acc = @instances.inject(acc) { |acc, obj| acc & obj.try }
      end
    end

    def initialize(*args, &block)
      new = self
      self.class.instance_eval do
        @instances << new
      end
      super(*args, &block)
    end

    def self.run
      raise NotImplementedError, "run can only be called on inheriting classes"
    end

    def self.try
      raise NotImplementedError, "try can only be called on inheriting classes"
    end
  end
end
