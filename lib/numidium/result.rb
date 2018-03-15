# -- vim: set noexpandtab foldmarker==begin,=end :miv --

=begin
	┌────────────────────┐
	│ Result             │
	├────────────────────┤
	│ + success: boolean │
	│ + message: string  │
	│ - type:    symbol  │
	│ - origin:  string  │
	├────────────────────┤
	│ + to_s: string     │
	│ + tap: string      │
	│ + delegate: nil    │
	└────────────────────┘
=end

require_relative "refinements/string_indent.rb"

module Numidium
  class Result
		using StringIndent

    attr_reader :message, :success, :type
		def failed?() success==false; end
		def passed?() success==true;  end

    def initialize(arg, type=false, success=nil)
      if arg.is_a? Exception
        @message = arg.message
        @origin  = arg.backtrace_locations
				@type = :exception
      else
        @message = arg
        @origin  = caller_locations(2)
				case type
				when true, :pass
					@success = true
					@type = :pass
				when false, :fail
					@success = false
					@type = :fail
				when Symbol
					@success = success
					@type = type
				end
      end
    end

    def to_s(*args)
      output = [
        case type
				when :fail
					'-'
				when :pass
					'+'
				when :skip
					'~'
				else
					'?'
				end,
        message
      ]
			(!failed? ? [] : @origin.map{|e| "> " + e.to_s.indent})
				.unshift(output.join(" ")).join("\n")
    end

    def tap(number)
      [
        failed? ? "not ok" : "ok", # Optimistic; everything that isn't a fail is a pass
        number,
        message,
				(type==:skip) ? "# Skip" : nil,
      ].join(" ")
    end

    def origin
      @origin.dup
    end

		def origin=(orig)
			@origin = [orig.source_location.join(":")] or raise "New origin has no .source_location"
		end

    def delegate
      return @origin.shift && self
    end
  end
end
