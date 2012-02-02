
Gem::Specification.new do |s|
  s.name              = "plugin_manager"
  s.version           = "1.5"
  s.summary           = "A Ruby plugin loader"
  s.author            = "Daniel Lucraft"
  s.email             = "dan@fluentradical.com"
  s.homepage          = "http://github.com/danlucraft/plugin_manager"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README.md)
  s.rdoc_options      = %w(--main README.md)

  s.files             = %w(README.md Rakefile) + Dir.glob("{spec,lib/**/*}")
  s.executables       = []
  s.require_paths     = ["lib"]

  s.add_development_dependency("rspec")
end
