# -- vim: set noexpandtab foldmarker==begin,=end :miv --

module Numidium
  @version = [0, 6, 3, :dev].freeze
	def self.version
		return @version
	end

	class Failed < StandardError; end

	# Because sometimes you really just need assert :)
	def assert(message=nil, &block)
		raise(Failed, message) unless block.call
	end
end
