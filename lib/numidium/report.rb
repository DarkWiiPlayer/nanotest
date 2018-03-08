# vim: set noexpandtab :miv
require_relative "result"
module Numidium
  class Report
		attr_reader :success, :num_failed
    def initialize(opts={})
			@success = nil
			@num_failed = nil
			@items = []
			@title = opts[:title] || "%s"
    end
		def origin() nil; end

    def display(depth=0, opts={})
			id = "  " * depth
      lines = @items.map do |item|
				pref = opts[:prefix_pass] || " "
				pref_fail = opts[:prefix_fail] || ">"
        case item
				when Result
					if item.success then
						pref + id + item.message + "\n"
					else
						pref_fail + id + item.message + "\n" +
							item.origin.map{|p| pref+id+"  "+p.to_s}.join("\n")
					end
        when Report
          item.display(depth+1, opts)
				else
					raise "Don't know how to parse: #{item.inspect}"
        end
			end
			lines.unshift(id + @title % @description) if @description
			lines.join("\n")
    end

    def to_s
      display
    end

		def set_items(ary)
			raise ArgumentError unless ary.is_a? Array
			@items = ary.dup.freeze

			@num_failed = @items.inject(0) do |acc, item|
				case item
				when Result
					item.success && acc || acc+1
				when Report
					acc + item.num_failed
				else
					acc
				end
			end
			@success = @num_failed==0

			self
		end

		def description=(str)
			raise ArgumentError unless str.is_a? String
			raise RuntimeError "Description has already been set!" if @description
			@description=str
		end
		def set_description(str=nil) self.description=str; self; end
  end
end
