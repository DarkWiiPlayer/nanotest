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

    attr_reader :message, :success

    def initialize(arg, success=false, type=:test)
      if arg.is_a? Exception
        @message = arg.message
        @origin  = arg.backtrace_locations
      else
        @message = arg
        @origin  = caller_locations(2)
      end
      @success = success
    end

    def to_s(*args)
      output = [
        success ? "+" : "-",
        message
      ]
			(@success ? [] : @origin.map{|e| "> " + e.to_s.indent})
				.unshift(output.join(" ")).join("\n")
    end

    def tap(number)
      [
        success ? "ok" : "not ok",
        number,
        message,
      ].join(" ")
    end

    def origin
      @origin.dup
    end

		def origin=(orig)
			@origin = [orig.source_location.join(":")] or raise "New origin has no .source_location" #TODO: proper error msg
		end

    def delegate
      return @origin.shift && self
    end
  end
end
