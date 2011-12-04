# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-mapme_at"
  s.version     = "0.0.1" 
  s.authors     = ["mcknut"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{A mapme.at Siri Proxy Plugin}
  s.description = %q{This plugin will allow users to check in at the current location or other locations by visiting a web page. }

  s.rubyforge_project = "siriproxy-mapme_at"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "oauth"
end
