class Nanotest
  module Common
    def self.raises?(expr, except=nil, b=binding, *args)
      except = except || StandardError
      begin
        if expr.is_a? String then
          eval(expr, b)
        else
          expr.call(*args)
        end
        return false
      rescue except => e
        return e
      rescue StandardError => e
        return false
      end
    end
  end
end
