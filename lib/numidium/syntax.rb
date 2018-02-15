# vim: set noexpandtab list:
class Numidium
	module Syntax
		def self.string(str, opts={})
			message =
				opts[:message] ||
				"The syntax of #{opts[:name] || "the provided string"} should be correct."
			[
				message,
				lambda do |*args|
					begin
						RubyVM::InstructionSequence.compile(
							str,
							opts[:file] || opts[:name] || "<test string>",
							opts[:path],
							opts[:line]
						)
						true
					rescue SyntaxError => e
						case opts[:verbose]
						when true
							message + "\n" + e.message
						else
							message
						end
					end
				end
			]
		end

		def self.file(file, opts={})
			message =
				opts[:message] ||
				"The syntax of #{opts[:name] || file} should be correct."
			[
				message,
				lambda do |*args|
					begin
						RubyVM::InstructionSequence.compile_file(file)
						true
					rescue SyntaxError => e
						case opts[:verbose]
						when true
							message + "\n" + e.message
						else
							message
						end
					end
				end
			]
		end
	end
end
