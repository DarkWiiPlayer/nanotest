require_relative "../lib/numidium/test"

assert("Numidium should be defined") { defined? Numidium }
assert("Numidium should be a module") { Numidium.is_a? Module }
assert("Numidium should have a version") { Numidium.version }
assert("Version should be an array") { Numidium.version.is_a? Array }
assert("Version should be 3 or 4 elements long") do
  Numidium.version.length == 3 or Numidium.version.length == 4
end
assert("Version should be frozen to avoid accidental tampering") do
  Numidium.version.frozen?
end

assert("Numidium should define the 'failed' exception class") do
  Numidium::Failed and Numidium::Failed.is_a? Class
end
