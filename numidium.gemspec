require_relative "lib/numidium"

Gem::Specification.new do |spec|
  spec.name = "numidium"
  spec.version = Numidium.version.join "."
  spec.authors = ["Dennis Fischer"]
  spec.email   = ["dennis.fischer.wasd@gmail.com"]
  spec.summary = "A minimalistic TDD library"
  spec.description = "A minimal TDD library aimed at providing a simple interface that can be learned in less than 10 minutes and a few functions that generate tests for common cases"
  spec.licenses = ["MIT"]
  spec.files = []
	spec.files << "lib/numidium.rb"
	spec.files << "lib/numidium/eval.rb"
	spec.files << "lib/numidium/syntax.rb"
  spec.files << "license.txt"
	
  spec.require_paths = ["lib"]
end
