# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'media_rename/version'

Gem::Specification.new do |spec|
  spec.name          = "media_rename"
  spec.version       = MediaRename::VERSION
  spec.authors       = ["John Tajima"]
  spec.email         = ["manjiro@gmail.com"]

  spec.summary       = %q{Gem that renames media files based on Plex content}
  spec.description   = %q{rename media files by comparing against what Plex db says}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "mocha"
  
  spec.add_dependency "liquid"
  spec.add_dependency "thor"
end
