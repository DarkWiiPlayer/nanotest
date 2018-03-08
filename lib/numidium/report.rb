# vim: set noexpandtab :miv
module Numidium
  class Report
    def initialize(opts={})
			@items = []
			@title = opts[:title] || "%s"
    end

    def display(depth=0, opts={})
			id = "  " * depth
      lines = @items.map do |item|
				pref = opts[:prefix_pass] || " "
				pref_fail = opts[:prefix_fail] || ">"
        case item
				when String
					pref + id + item
        when Hash
					pref = pref_fail unless item[:success]
					pref + id + "#{item[:message]} (#{item[:src].join(':')})"
				when Exception
					pref_fail + id + "#{item.message} in" +
						item.backtrace.map{|e| "\n" + id + " ..." + e.to_s}.join
        when Report
          item.display(depth+1, opts)
				else
					"Don't know how to parse: #{item.inspect}"
        end
			end
			lines.unshift(id + @title % @description) if @description
			lines.join("\n")
    end

    def to_s
      display
    end

		def count_failed
			@items.inject(0) do |acc, item|
				case item
				when String
					acc
				when Hash
					acc + (item[:success] ? 0 : 1)
				when Report
					acc + item.count_failed
				else
					acc
				end
			end
		end

		def failed?
			count_failed > 0
		end

		def passed?
			count failed == 0
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
