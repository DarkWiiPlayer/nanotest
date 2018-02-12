# vim: set noexpandtab:

class Numidium
	module Eval
		module Helper
			def self.raises?(expr, except=nil, b=binding, *args)
				except = except || StandardError
				begin
					if expr.is_a? String then
						eval(expr, b)
					else
						expr.call(*args)
					end
					return false
				rescue except => e
					return e
				end
			end

			def self.run expr, binding, *args
				if expr.respond_to?(:call) then
					return expr.(*args)
				else
					return eval expr, binding
				end
			end
		end

		def self.truthy(subject=nil, opts={}, &block)
			opts = subject if subject.is_a?(Hash)
			subject = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless subject.respond_to?(:call) or subject.is_a? String
				Subject is #{subject.class}, expected Proc or String
			ERROR
			message = opts[:message].to_s + "#{opts[:message] ? "\n" : nil}Expect `#{opts[:name] || subject}` to be truthy"
			[
				message,
				lambda do |*args|
					res = Helper::run subject, opts[:binding], *args
					!!res || message + ", got #{res}"
				end
			]
		end

		def self.falsey(subject=nil, opts={}, &block)
			opts = subject if subject.is_a?(Hash)
			subject = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless subject.respond_to?(:call) or subject.is_a? String
				Subject is #{subject.class}, expected Proc or String
			ERROR
			message = opts[:message].to_s + "#{opts[:message] ? "\n" : nil}Expect `#{opts[:name] || subject}` to be falsey"
			[
				message,
				lambda do |*args|
					res = Helper::run subject, opts[:binding], *args
					!res || message + ", got #{res}"
				end
			]
		end

		def self.equal(subject_1, subject_2, opts={})
			message = opts[:message] || "`#{opts[:name_1] || subject_1}` should equal `#{opts[:name_2] || subject_2}`"
			[
				message,
				lambda do |*args|
					res1 = Helper::run subject_1, Array(opts[:binding]).first, *args
					res2 = Helper::run subject_2, Array(opts[:binding]).last,	*args
					res1==res2 || message + "\nExpected:\n#{res2.inspect}\nGot:\n#{res1.inspect}"
				end,
			]
		end

		def self.unequal(subject_1, subject_2, opts={})
			message = opts[:message] || "`#{opts[:name_1] || subject_1}` should not equal `#{opts[:name_2] || subject_2}`"
			[
				message,
				lambda do |*args|
					res1 = Helper::run subject_1, Array(opts[:binding]).first, *args
					res2 = Helper::run subject_2, Array(opts[:binding]).last,	*args
					res1 != res2 || message + "\nBoth evaluate to\n#{res1}"
				end,
			]
		end

		def self.succeeds(subject=nil, opts={}, &block)
			opts = subject if subject.is_a?(Hash)
			subject = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless subject.respond_to?(:call) or subject.is_a? String
				Subject is #{subject.class}, expected Proc or String
			ERROR
			message = opts[:message] || "'#{opts[:name_1] || subject}' should succeed without errors"
			[
				message,
				lambda do |*args|
					!Helper::raises?(subject, opts[:exception], opts[:binding], *args)
				end,
			]
		end

		def self.fails(subject=nil, opts={}, &block)
			opts = subject if subject.is_a?(Hash)
			subject = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless subject.respond_to?(:call) or subject.is_a? String
				Subject is #{subject.class}, expected Proc or String
			ERROR
			message = opts[:message] || "'#{opts[:name_1] || subject}' should fail with an error"
			[
				message,
				lambda do |*args|
					Helper::raises?(subject, opts[:exception], opts[:binding], *args)
				end ,
			]
		end

		def self.maps(table, subject=nil, opts={}, &block)
			opts = subject if subject.is_a?(Hash)
			subject = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless subject.respond_to?(:call) or subject.is_a? String
				Subject is #{subject.class}, expected Proc/Method or String
			ERROR
			if opts[:split] then
				table.each.each_with_object([]) do |args_value, subtests|
					args, value = args_value
					message = opts[:message] ||
						"`#{opts[:name] || subject}` should map\n`#{args.inspect}` => `#{value.inspect}`"
					subtests << [ message,
						proc do
							begin
								result = Helper::run(subject, opts[:binding], *args)
							rescue Exception => e
								raise e if opts[:noraise]
								result = e.class
							end
							if result == value
								true
							else
								message+"\nbut mapped it to `#{result.inspect}` instead"
							end
						end
					]
				end
			else
				message = opts[:message] || "`#{opts[:name] || subject}` should evaluate each key to its corresponding value."
				[ message,
					lambda do |*_|
						table.each do |args, value|
							begin
								result = Helper::run(subject, opts[:binding], *args)
							rescue Exception => e
								raise e if opts[:noraise]
								result = e.class
							end
							unless result == value
								return message+"\n"+<<~EOL
								Incorrectly mapped
								\t#{Array(args).map(&:inspect).join(", ")} to
								\t#{result.inspect} (#{result.class}), expected
								\t#{value.inspect} (#{value.class})
								EOL
							end
						end
						return true
					end
				]
			end # if-else opts[:split]
		end # def maps
	end
end
