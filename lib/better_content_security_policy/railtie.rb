# frozen_string_literal: true

# Require the concern class
module BetterContentSecurityPolicy
  class Railtie < Rails::Railtie
    initializer "better_content_security_policy" do
      require_relative "has_content_security_policy"
    end
  end
end
