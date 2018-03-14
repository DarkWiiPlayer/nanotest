# -- vim: set noexpandtab foldmarker==begin,=end :miv --

=begin Diagrams
	┌─────────────────────────────────┐
	│ Report                          │
	├─────────────────────────────────┤
	│ + success: boolean              │
	│ + num_failed: integer           │
	├─────────────────────────────────┤
	│ + origin: [nil]                 │
	│ + to_s: string                  │
	│ + to_a: array                   │
	│ + tap: string                   │
	│ + set_items(array): self        │
	│ + set_description(string): self │
	└─────────────────────────────────┘

	The items array contains a list of Result objects
	and nested Reports.

	Items ─┐
	       ├─ Some Result
	       ├─ Some other Result
	       ├─┬─ Another Report
	       │ ├─ Moar Result
	       │ └─ ...
	       ├─ Another Result
	       └─ ...
=end

require_relative "result"
require_relative "refinements/string_indent"

module Numidium
  class Report
		using StringIndent

		attr_reader :success, :num_failed
    def initialize(opts={})
			@success = nil
			@num_failed = nil
			@items = []
			@title = opts[:title] || "%s"
    end
		def origin() [nil]; end

    def tap
      res = to_a.each_with_index.map{|e,idx| e.tap(idx+1)}
      res.unshift("#{1}..#{res.length}")
    end

    def to_a(nested=false)
      res = []
      @items.each do |item|
        case item
        when Result
          res << item
        when Report
          if not nested then
            res.push(*item.to_a(nested))
          else
            res.push(item.to_a(nested))
          end
        else
          raise "Weird element :|"
        end
      end
      res
    end

    def to_s(depth=0, opts={})
      lines = @items.map do |item|
        case item
				when Result
					item.to_s.indent(depth)
        when Report
          item.to_s(depth+1)
				else
					raise "Don't know how to parse: #{item.inspect}"
        end
			end

			lines.unshift(@description.indent(depth)) unless opts[:notitle] if @description

			lines.join("\n")
    end

		def set_items(ary)
			raise ArgumentError unless ary.is_a? Array
      @items = ary.dup

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
