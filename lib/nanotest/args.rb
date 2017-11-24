require "nanotest/common"

class Nanotest
  module Args
    def self.equal()
      [
        "Arguments should be equal",
        -> (a,b) { a==b or "#{a} and #{b} should be equal!" },
      ]
    end

    def self.unequal()
      [
        "Arguments should be unequal",
        -> (a,b) { a!=b or "#{a} and #{b} should be unequal!" },
      ]
    end
  end
end
