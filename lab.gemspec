# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'lab/version'

Gem::Specification.new do |s|
  s.name        = "lab"
  s.version     = Lab::VERSION
  s.authors     = ["Jonathan Cran"]
  s.email       = ["jcran@rapid7.com"]
  s.homepage    = "http://www.github.com/rapid7/lab/wiki"
  s.summary     = %q{Manage VMs like a boss}
  s.description = %q{Start/Stop/Revert and do other cool stuff w/ Vmware, Virtualbox, and ESXi vms. This gem wraps common CLI utilities and other gems to create a common inteface for vms. }

  s.rubyforge_project = "lab"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"

    # ??
    s.add_runtime_dependency "nokogiri"

    # Multiple things - fallback execute / copy
    s.add_runtime_dependency "net-ssh"
    s.add_runtime_dependency "net-scp"

    # Vmware vsphere driver
    s.add_runtime_dependency "rbvmomi"
    
end
