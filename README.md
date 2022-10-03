![Ruby CI builds](https://github.com/DocSpring/better_content_security_policy/actions/workflows/main.yml/badge.svg)

# Better Content Security Policy

This gem makes it easy to configure a dynamic `Content-Security-Policy` header for your Rails application.
You can easily customize the rules in your controllers, and you can also update the rules in your views.

Read the MDN Web Docs to learn more about Content Security Policies: https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP

## Features

- Configure unique `Content-Security-Policy` rules for different controllers and actions.
- Configure `Content-Security-Policy` rules alongside `script` tags in your views, so that rendering a view partial will automatically add all of the required CSP rules for those resources.
- Still uses some features from Rails, such as `Rails.application.config.content_security_policy_nonce_generator` to generate nonce values.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add better_content_security_policy

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install better_content_security_policy

## Usage

Include the `BetterContentSecurityPolicy::HasContentSecurityPolicy` concern in your `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  include BetterContentSecurityPolicy::HasContentSecurityPolicy
```

Define a `#configure_content_security_policy` method in `ApplicationController` to configure the default `Content-Security-Policy` rules:

```ruby
  def configure_content_security_policy
    content_security_policy.default_src :none
    content_security_policy.font_src :self
    content_security_policy.script_src :self
    content_security_policy.style_src :self
    content_security_policy.img_src :self
    content_security_policy.connect_src :self
    content_security_policy.prefetch_src :self

    content_security_policy.report_uri = "http://example.com/csp_reports"
    content_security_policy.report_only = true
  end
```

You can define more `#configure_content_security_policy` methods in any other controllers. Call `super` if you want to inherit your default configuration from ApplicationController. Otherwise, you can omit the call to `super` if you want to start from scratch with a new policy.

You are now able to access content_security_policy in your controllers and views. After you have finished rendering the response, an `after_action` callback will generate and add the `Content-Security-Policy` header.

## Examples

#### Plausible Analytics

Here's an example `HAML` partial that includes the JavaScript snippet for [Plausible Analytics](https://plausible.io/).

```haml
# app/views/layouts/_plausible_analytics.html.haml

- if PLAUSIBLE_ANALYTICS_HOST
  - content_security_policy.connect_src PLAUSIBLE_ANALYTICS_HOST
  - content_security_policy.script_src PLAUSIBLE_ANALYTICS_HOST
  = javascript_include_tag "#{PLAUSIBLE_ANALYTICS_HOST}/js/script.js", defer: true, data: { domain: local_assigns[:domain].presence || request.host }
  = javascript_tag nonce: true do
    window.plausible = window.plausible || function() { (window.plausible.q = window.plausible.q || []).push(arguments) }
```

Whenever this view partial is rendered, the connect-src and script-src directives will be automatically added to your `Content-Security-Policy` header.

#### Gravatar Images

You can also override any helper methods that add resources from external sites, and update them so that they will automatically add the required `Content-Security-Policy` rules. Here's the overridden helper method that I use to generate Gravatar image URLs:

```ruby
  def gravatar_image_url(email, options = {})
    content_security_policy.img_src 'https://secure.gravatar.com'
    content_security_policy.img_src 'https://*.wp.com'
    super
  end
```

> Note: It's fine to call this method multiple times. Any duplicate entries are automatically removed.

## Nonces

This gem does not need to provide any extra functionality for working with `nonce` values. You can still set up the Rails nonce generator in `config/initializers/content_security_policy.rb`:

```ruby

Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
```

The Rails `content_security_policy?` method will return false since we are not using the CSP feature from Rails, so the `csp_meta_tag` helper will not work. You will need to create the meta tag manually:

```
<%= tag("meta", name: "csp-nonce", content: content_security_policy_nonce) %>
```

You must also manually set up the `nonce-*` value in your `#configure_content_security_policy` method:

```ruby
  def configure_content_security_policy
    content_security_policy.script_src :self, "nonce-#{content_security_policy_nonce}"
    # ...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/better_content_security_policy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/better_content_security_policy/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BetterContentSecurityPolicy project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/better_content_security_policy/blob/main/CODE_OF_CONDUCT.md).
