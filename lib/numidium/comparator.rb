# -- vim: set noexpandtab foldmarker==begin,=end :miv --

module Numidium
  class Comparator
    def initialize(method=:real, &block)
      @method = method
      @reference = Benchmark::measure(&block).send(@method)
    end

    def compare(&block)
      Benchmark::measure(&block).send(@method) / @reference
    end
  end
end
