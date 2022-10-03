# Better Content Security Policy

This gem makes it easy to configure a dynamic `Content-Security-Policy` header for your Rails application.
You can easily customize the rules in your controllers, and you can also update the rules in your views.

Read the MDN Web Docs to learn more about Content Security Policies: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP

## Features

- Configure a unique `Content-Security-Policy` header for different controllers and actions.
- Add `Content-Security-Policy` rules next to the script tags in your views. Rendering a view partial will automatically add the CSP rules for that partial.
- Still uses some features from Rails, such as `Rails.application.config.content_security_policy_nonce_generator` to generate nonce values.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add better_content_security_policy

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install better_content_security_policy

## Usage

Configure the nonce generator for Rails in `config/initializers/content_security_policy.rb`:

```ruby
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
```

Include the `BetterContentSecurityPolicy::HasContentSecurityPolicy` concern in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  include BetterContentSecurityPolicy::HasContentSecurityPolicy
```

Define a `#configure_content_security_policy` method to configure the default `Content-Security-Policy` header (also in `ApplicationController`):

```ruby
  def configure_content_security_policy
    content_security_policy.default_src :none
    content_security_policy.font_src :self
    content_security_policy.script_src :self, "nonce-#{content_security_policy_nonce}"
    content_security_policy.style_src :self
    content_security_policy.img_src :self
    content_security_policy.connect_src :self
    content_security_policy.prefetch_src :self
    content_security_policy.report_uri = "http://example.com/csp_reports"
    content_security_policy.report_only = true
  end
```

You can define the `#configure_content_security_policy` in any other controllers. Call `super` to inherit your default configuration from `ApplicationController`, or you can omit `super` to start from scratch.

You can now access `content_security_policy` in your controllers and views. After your response has been rendered, the `Content-Security-Policy` header will be added to the response.

### Example

Here is an example `ERB` partial that includes a JavaScript snippet for [Plausible Analytics](https://plausible.io/).

```erb
# app/views/layouts/_plausible_analytics.html.erb

<% if PLAUSIBLE_ANALYTICS_HOST %>
    <script defer data-domain="<%= local_assigns[:domain].presence || request.host %>" src="<%= PLAUSIBLE_ANALYTICS_HOST %>/js/script.js"></script>
    <script nonce="<%= content_security_policy.nonce(:script) %>">
        window.plausible = window.plausible || function() { (window.plausible.q = window.plausible.q || []).push(arguments) }
    </script>
<%
content_security_policy.connect_src PLAUSIBLE_ANALYTICS_HOST
content_security_policy.script_src PLAUSIBLE_ANALYTICS_HOST
%>
<% end %>
```

Rendering this view partial will add `connect-src` and `script-src` sources for the Plausible Analytics host to the `Content-Security-Policy` header.
A nonce is generated for the inline script tag that sets `window.plausible`, and this nonce is also added to the `Content-Security-Policy` header.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/better_content_security_policy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/better_content_security_policy/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BetterContentSecurityPolicy project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/better_content_security_policy/blob/main/CODE_OF_CONDUCT.md).
