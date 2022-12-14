# frozen_string_literal: true

require "active_support/concern"

module BetterContentSecurityPolicy
  # Include this module in your ApplicationController to configure a dynamic Content Security Policy.
  # The header will be set in an after_action after the response has been rendered.
  # This means that you can also modify the policy in your views.
  # You must call 'after_action :set_content_security_policy_header' in your own controller.
  module HasContentSecurityPolicy
    extend ActiveSupport::Concern

    included do
      private :set_content_security_policy_header, :content_security_policy

      helper_method :content_security_policy
      before_action :configure_content_security_policy
    end

    def content_security_policy
      @content_security_policy ||= BetterContentSecurityPolicy::ContentSecurityPolicy.new
    end

    # Override this method in your controller to configure the content security policy.
    # Call `super` if you want to inherit the parent controller's policy.
    def configure_content_security_policy; end

    def set_content_security_policy_header
      response.headers.merge!(content_security_policy.to_h)
    end
  end
end
