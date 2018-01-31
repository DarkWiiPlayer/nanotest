# vim: set noexpandtab:

class Nanotest
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

		def self.truthy(expr=nil, opts={}, &block)
			opts = expr if expr.is_a?(Hash)
			expr = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless expr.respond_to?(:call) or expr.is_a? String
				Expression is #{expr.class}, expected Proc or String
			ERROR
			message = opts[:message].to_s + "#{opts[:message] ? "\n" : nil}Expect `#{expr}` to be truthy"
			[
				message,
				lambda do |*args|
					res = Helper::run expr, opts[:binding], *args
					!!res || message + ", got #{res}"
				end
			]
		end

		def self.falsey(expr=nil, opts={}, &block)
			opts = expr if expr.is_a?(Hash)
			expr = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless expr.respond_to?(:call) or expr.is_a? String
				Expression is #{expr.class}, expected Proc or String
			ERROR
			message = opts[:message].to_s + "#{opts[:message] ? "\n" : nil}Expect `#{expr}` to be falsey"
			[
				message,
				lambda do |*args|
					res = Helper::run expr, opts[:binding], *args
					!res || message + ", got #{res}"
				end
			]
		end

		def self.equal(exp1, exp2, opts={})
			message = opts[:message] || "`#{exp1}` should equal `#{exp2}`"
			[
				message,
				lambda do |*args|
					res1 = Helper::run exp1, Array(opts[:binding]).first, *args
					res2 = Helper::run exp2, Array(opts[:binding]).last,	*args
					res1==res2 || message + "\nExpected:\n#{res2.inspect}\nGot:\n#{res1.inspect}"
				end,
			]
		end

		def self.unequal(exp1, exp2, opts={})
			message = opts[:message] || "`#{exp1}` should not equal `#{exp2}`"
			[
				message,
				lambda do |*args|
					res1 = Helper::run exp1, Array(opts[:binding]).first, *args
					res2 = Helper::run exp2, Array(opts[:binding]).last,	*args
					res1 != res2 || message + "\nBoth evaluate to\n#{res1}"
				end,
			]
		end

		def self.succeeds(expr=nil, opts={}, &block)
			opts = expr if expr.is_a?(Hash)
			expr = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless expr.respond_to?(:call) or expr.is_a? String
				Expression is #{expr.class}, expected Proc or String
			ERROR
			message = opts[:message] || "Expression '#{expr}' should succeed without errors"
			[
				message,
				lambda do |*args|
					!Helper::raises?(expr, opts[:exception], opts[:binding], *args)
				end,
			]
		end

		def self.fails(expr=nil, opts={}, &block)
			opts = expr if expr.is_a?(Hash)
			expr = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless expr.respond_to?(:call) or expr.is_a? String
				Expression is #{expr.class}, expected Proc or String
			ERROR
			message = opts[:message] || "'Expression #{expr}' should fail with an error"
			[
				message,
				lambda do |*args|
					Helper::raises?(expr, opts[:exception], opts[:binding], *args)
				end ,
			]
		end

		def self.maps(table, expr=nil, opts={}, &block)
			opts = expr if expr.is_a?(Hash)
			expr = block if block.respond_to?(:call)
			raise ArgumentError, <<~ERROR unless expr.respond_to?(:call) or expr.is_a? String
				Expression is #{expr.class}, expected Proc/Method or String
			ERROR
			message = opts[:message] || "`#{expr}` should evaluate each key to its corresponding value."
			[
				message,
				lambda do |*_|
					table.each do |args, value|
						begin
							result = Helper::run(expr, opts[:binding], *args)
						rescue Exception => e
							raise e if opts[:noraise]
							result = e.class
						end
						unless result == value
							return message+"\nIncorrectly mapped\n#{Array(args).join(", ")}\nto\n#{result}\nexpected\n#{value}"
						end
					end
					return true
				end
			]
		end
	end
end
