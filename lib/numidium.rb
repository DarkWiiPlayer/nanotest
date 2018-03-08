# vim: set noexpandtab :miv
module Numidium
  @version = [0, 6, 0, :dev].freeze
	def self.version
		return @version
	end

	class Failed < StandardError; end
end

require_relative "numidium/test"
# require_relative "numidium/suite"
