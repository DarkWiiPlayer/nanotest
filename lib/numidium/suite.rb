require_relative "../numidium"

class Numidium
  class Suite < Numidium
    def self.inherited(subclass)
      subclass.instance_eval do
        @subclasses = []
        @instances  = []
        @params     = []
      end
      def subclass.inherited(subclass)
        @subclasses << subclass
        subclass.instance_eval do
          @subclasses = []
          @instances  = []
          @params     = []
        end
      end
      def subclass.run(*args)
        args = [*@params, *args]
        acc = 0
        acc = @subclasses.inject(acc) { |acc, sub| acc + sub.run(*args) }
        acc = @instances.inject(acc) { |acc, obj| acc + obj.run(*args) }
      end
      def subclass.try(*args)
        args = [*@params, *args]
        acc = true
        acc = @subclasses.inject(acc) { |acc, sub| acc && sub.try(*args) }
        acc = @instances.inject(acc) { |acc, obj| acc && obj.try(*args) }
      end
    end

    def self.params
      @params.dup.freeze
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
