# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-json-input"
  gem.description = "Json input via tcp stream pluging for fluentd."
  gem.homepage    = "https://github.com/uchann2/fluentd-plugin-json-input.git"
  gem.summary     = gem.description
  gem.version     = File.read("VERSION").strip
  gem.authors     = ["Nayanajith Sandaruwan Chandradasa"]
  gem.email       = "nayanajithsc@gmail.com"
  gem.has_rdoc    = false
  #gem.platform    = Gem::Platform::RUBY
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']
  gem.license = "Apache-2.0"

  gem.add_dependency "fluentd", [">= 1.2.2"]
  gem.add_development_dependency "rake", ">= 12.0.0"
  gem.add_development_dependency "test-unit", "> 3.2.3"
end