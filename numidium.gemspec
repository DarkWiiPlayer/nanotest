require_relative "lib/numidium/version"

Gem::Specification.new do |spec|
  spec.name = "numidium"
  spec.version = Numidium.version.join "."
  spec.homepage   = 'https://github.com/DarkWiiPlayer/numidium'
  spec.metadata    = { "source_code_uri" => "https://github.com/DarkWiiPlayer/numidium" }
  spec.authors = ["Dennis Fischer"]
  spec.email   = ["dennis.fischer.wasd@gmail.com"]
  spec.summary = "A minimalistic TDD library"
  spec.description = "A minimal TDD library aimed at providing a simple interface that can be learned in less than 10 minutes and a few functions that generate tests for common cases"
  spec.licenses = ["MIT"]
  spec.files = []

	spec.files << "lib/numidium.rb"

	spec.files << "lib/numidium/version.rb"
	spec.files << "lib/numidium/eval.rb"
	spec.files << "lib/numidium/syntax.rb"
	spec.files << "lib/numidium/suite.rb"
	spec.files << "lib/numidium/block.rb"

  spec.files << "rakefile"
  Dir.glob("tests/*").each { |file| spec.files << file }

  spec.files << "license.txt"
  spec.files << "readme.md"

  spec.require_paths = ["lib"]
end
