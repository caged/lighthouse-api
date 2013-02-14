Gem::Specification.new do |s|
  s.name = %q{lighthouse-api}
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rick Olson", "Justin Palmer"]
  s.email = ["justin@entp.com"]
  s.extra_rdoc_files = ["LICENSE"]
  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  s.has_rdoc = true
  s.homepage = 'http://lighthouseapp.com/api'
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = 'lighthouse'
  s.rubygems_version = '1.2.0'
  s.summary = %q{Ruby API wrapper for Lighthouse - http://lighthouseapp.com}
  s.description = %q{Ruby API wrapper for Lighthouse - http://lighthouseapp.com}
  s.test_files = []

  s.add_dependency(%q<activesupport>, [">= 3.0.0"])
  s.add_dependency(%q<activeresource>, [">= 3.0.0"])
end
