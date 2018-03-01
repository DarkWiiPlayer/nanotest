# vim: set noexpandtab :miv
module Numidium
  class Report
    def initialize()
			@items = []
    end

    def display(depth=0)
			id = "  " * depth
      lines = @items.map do |item|
        case item
				when String
					id + item
        when Hash
					id + "#{item[:message]} (#{item[:src].join(':')})"
				when Exception
					id + "#{item.message} in" +
						item.backtrace.map{|e| "\n" + id + " ..." + e.to_s}.join
        when Report
          item.display(depth+1)
				else
					"Don't know how to parse: #{item.inspect}"
        end
			end
			lines.unshift(id + @description) if @description
			lines.join("\n")
    end

    def to_s
      display
    end

		def items=(ary)
			raise ArgumentError unless ary.is_a? Array
			@items=ary.dup
		end
		def set_items(ary=nil) self.items=ary; self; end

		def description=(str)
			raise ArgumentError unless str.is_a? String
			raise RuntimeError "Description has already been set!" if @description
			@description=str
		end
		def set_description(str=nil) self.description=str; self; end
  end
end
