# -- vim: set noexpandtab :miv --

=begin {{{
# ┌────────────────────┐
# │ Result             │
# ├────────────────────┤
# │ + success: boolean │
# │ + message: string  │
# │ + type:    symbol  │
# ├────────────────────┤
# │ + to_s: string     │
# │ + delegate: nil    │
# └────────────────────┘
=end }}}

module Numidium
  class Result
    attr_reader :message, :success

    def origin
      @origin.dup
    end

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
      [
        success ? "+" : "-",
        message
      ].join(" ")
    end

    def tap(number)
      [
        success ? "ok" : "not ok",
        number,
        message,
      ].join(" ")
    end

    def delegate
      return @origin.shift && self
    end
  end
end
