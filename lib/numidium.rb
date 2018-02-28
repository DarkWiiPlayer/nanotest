# vim: set noexpandtab :miv
module Numidium
  @version = [0, 6, 0, :dev].freeze
	def self.version
		return @version
	end

	# TODO: anonymous tests
	class Failed < StandardError; end
end
