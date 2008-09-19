Gem::Specification.new do |s|
  s.name = %q{lighthouse-api}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rick Olsen", "Justin Palmer"]
  s.date = %q{2008-09-19}
  s.description = %q{RubyGem wrapper for ActiveResource API to http://lighthouseapp.com}
  s.email = ["FIXME email"]
  s.extra_rdoc_files = ["LICENSE"]
  s.files = ["LICENSE", "README.markdown", "lib/lighthouse-api.rb", "lib/lighthouse.rb", "lib/lighthouse/console.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://lighthouseapp.com/api}
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{lighthouse}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{RubyGem wrapper for ActiveResource API to http://lighthouseapp.com}
  s.test_files = []

  s.add_dependency(%q<activesupport>, [">= 2.1.0"])
  s.add_dependency(%q<activeresource>, [">= 2.1.0"])
  
end
