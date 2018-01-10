require_relative "lib/nanotest"

Gem::Specification.new do |spec|
  spec.name = "nanotest"
  spec.version = Nanotest.version.join "."
  spec.authors = ["Dennis Fischer"]
  spec.email   = ["dennis.fischer.wasd@gmail.com"]
  spec.summary = "A simple TDD class"
  spec.description = "A minimal TDD class aimed at providing a simple interface that can be learned in 10 minutes or less and a few functions that generate tests for common cases"
  spec.licenses = ["MIT"]
  spec.files = []
	spec.files << "lib/nanotest.rb"
	spec.files << "lib/nanotest/eval.rb"
  spec.files << "license.txt"
	
  spec.require_paths = ["lib"]
end
