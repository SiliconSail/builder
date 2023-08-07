require_relative "lib/envirobly_builder/version"

Gem::Specification.new do |spec|
  spec.name        = "envirobly-builder"
  spec.version     = EnviroblyBuilder::VERSION
  spec.authors     = ["Robert Starsi"]
  spec.email       = "klevo@klevo.sk"
  spec.homepage    = "https://klevo.sk"
  spec.summary     = "Envirobly Builder"
  spec.license     = "Copyright 2023 Robert Starsi. All rights reserved."

  spec.files = Dir["lib/**/*", "LICENSE"]
  spec.executables = %w[envirobly-builder]

  # spec.add_dependency "activesupport", ">= 7.0"
  spec.add_dependency "thor"
  spec.add_dependency "zeitwerk"
  spec.add_dependency "httparty"

  spec.add_development_dependency "debug"
  # spec.add_development_dependency "railties"
end
