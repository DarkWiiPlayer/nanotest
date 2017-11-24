class Nanotest
  module Common
    def self.raises?(expr, b=binding, *args)
      begin
        if expr.is_a? String then
          eval(expr, b)
        else
          expr.call(*args)
        end
        return false
      rescue StandardError => e
        return e
      end
      return false
    end
  end
end
