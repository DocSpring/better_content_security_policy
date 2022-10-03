# frozen_string_literal: true

require_relative "lib/better_content_security_policy/version"

Gem::Specification.new do |spec|
  spec.name = "better_content_security_policy"
  spec.version = BetterContentSecurityPolicy::VERSION
  spec.authors = ["Nathan Broadbent"]
  spec.email = ["nathan@docspring.com"]

  spec.summary = "Configure a dynamic Content-Security-Policy header that you can customize in your controllers."
  spec.description = "This gem makes it easy to configure a dynamic Content-Security-Policy header " \
                     "for your Rails application. You can easily customize the rules in your controllers, " \
                     "and you can also update the rules in your views."
  spec.homepage = "https://github.com/DocSpring/better_content_security_policy"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/DocSpring/better_content_security_policy"
  spec.metadata["changelog_uri"] = "https://github.com/DocSpring/better_content_security_policy/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "rails", ">= 5.0.0"
end
