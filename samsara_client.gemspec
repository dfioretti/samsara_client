# frozen_string_literal: true

require_relative "lib/samsara_client/version"

Gem::Specification.new do |spec|
  spec.name = "samsara_client"
  spec.version = SamsaraClient::VERSION
  spec.authors = ["David Fioretti"]
  spec.email = ["fioretti.david@gmail.com"]

  spec.summary = "Samsara API Client"
  spec.description = "Basic functions for ruby samsara integration"
  spec.homepage = "https://github.com/dfioretti/samsara_client.git"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dfioretti/samsara_client.git"
  spec.metadata["changelog_uri"] = "https://github.com/dfioretti/samsara_client/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # Use Dir.glob instead of git ls-files for Docker compatibility
  gemspec = File.basename(__FILE__)
  spec.files = Dir.glob(File.join(__dir__, "**", "*"), File::FNM_DOTMATCH).
    map { |f| f.sub("#{__dir__}/", "") }.
    reject { |f| 
      f == gemspec || 
      f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile]) ||
      f.end_with?(".gem") ||
      File.directory?(File.join(__dir__, f))
    }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
