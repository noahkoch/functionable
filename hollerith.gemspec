Gem::Specification.new do |s|
  s.name        = 'hollerith'
  s.version     = '0.0.8'
  s.date        = '2019-09-16'
  s.summary     = "Create and run functions in JSON."
  s.description = "Trigger code through a series of hooks and run code in loops and through conditions."
  s.authors     = ["Noah Kochanowicz"]
  s.email       = 'me@noahkoch.com'
  s.homepage    = 'https://rubygems.org/gems/hollerith'
  s.license     = 'MIT'
  s.files       = ["lib/hollerith.rb", "lib/hollerith/utilities/value_getter.rb", "lib/hollerith/utilities/argument_decoder.rb", "lib/hollerith/system_functions.rb", "lib/hollerith/function_runner.rb"]

  s.add_dependency("deep_merge", "~> 1.2.1")
end
