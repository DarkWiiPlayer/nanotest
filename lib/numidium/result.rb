# ┌────────────────────┐
# │ Report             │
# ├────────────────────┤
# │ + success: boolean │
# │ + message: string  │
# │ + type:    symbol  │
# ├────────────────────┤
# │ + to_s: string     │
# │ + delegate: nil    │
# └────────────────────┘

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
    def to_s
      [
        success ? "pass:" : "FAIL:",
        message
      ].join(" ")
    end
    def delegate
      return @origin.shift && self
    end
  end
end
