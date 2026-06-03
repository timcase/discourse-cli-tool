# frozen_string_literal: true

require_relative "lib/discourse_cli/version"

Gem::Specification.new do |spec|
  spec.name = "discourse-cli-tool"
  spec.version = DiscourseCli::VERSION
  spec.authors = ["Tim Case"]
  spec.email = ["tim@2drops.net"]
  spec.summary = "CLI tool for managing Discourse forums from the command line"
  spec.homepage = "https://github.com/timcase/discourse-cli-tool"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files = Dir["lib/**/*", "exe/*"]
  spec.bindir = "exe"
  spec.executables = ["dsc"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "base64"
  spec.add_runtime_dependency "discourse_api", "~> 2.1"
  spec.add_runtime_dependency "thor", "~> 1.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
