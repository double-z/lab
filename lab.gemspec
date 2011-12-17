# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lab/version"

Gem::Specification.new do |s|
  s.name        = "lab"
  s.version     = Lab::VERSION
  s.authors     = ["Jonathan Cran"]
  s.email       = ["jcran@pentestify.com"]
  s.homepage    = "http://www.pentestify.com/projects/lab"
  s.summary     = %q{Manage vms like a boss.}
  s.description = %q{Start/Stop/Revert and do other cool stuff w/ Vmware, Virtualbox, and ESXi vms}

  s.rubyforge_project = "lab"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
   s.add_runtime_dependency "nokogiri"
end
