$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "e_commerce/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "e_commerce"
  s.version     = ECommerce::VERSION
  s.authors     = ["ZhouBin"]
  s.email       = ["idolifetime@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ECommerce."
  s.description = "TODO: Description of ECommerce."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"

  s.add_development_dependency "sqlite3"
end
