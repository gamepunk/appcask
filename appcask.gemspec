# frozen_string_literal: true

require_relative "lib/appcask/version"

Gem::Specification.new do |spec|
  spec.name = "appcask"
  spec.version = AppCask::VERSION
  spec.authors = ["Billow Wang"]
  spec.email = ["netheadonline@gmail.com"]

  spec.summary = "Download App Store app assets easily"
  spec.description = "AppCask is a CLI tool for downloading App Store icons, screenshots and metadata."
  spec.homepage = "https://github.com/gamepunk/appcask"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gamepunk/appcask"
  spec.metadata["changelog_uri"] = "https://github.com/gamepunk/appcask/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end

  spec.bindir = "exe"
  spec.executables = ["appcask"]
  spec.require_paths = ["lib"]
end
