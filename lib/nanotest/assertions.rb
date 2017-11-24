class Nanotest
  module Assert
    def self.compare(result, value)
      add "", #TODO
        -> do
          result = result.call
          unless result == value
            return "Test#{@name} failed: #{msg}\nExpected:\n#{value}\nGot:\n#{result}"
          end
        end
    end
  end
end
