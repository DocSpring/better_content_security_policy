# frozen_string_literal: true

module BetterContentSecurityPolicy
  # DSL for building a Content Security Policy.
  # An instance of this class will be available in your controllers and views.
  # You can call a method multiple times to add additional rules to the policy.
  class ContentSecurityPolicy
    DIRECTIVES = %w[
      base-uri
      child-src
      connect-src
      default-src
      font-src
      form-action
      frame-src
      img-src
      manifest-src
      media-src
      navigate-to
      object-src
      prefetch-src
      script-src
      style-src
      worker-src
    ].freeze

    SCHEME_SOURCES = %w[
      blob
      data
      filesystem
      http
      https
      mediastream
    ].freeze

    QUOTED_SOURCES = %w[
      none
      self
      unsafe-eval
      unsafe-hashes
      unsafe-inline
      wasm-unsafe-eval
    ].freeze

    attr_accessor :directives, :report_uri, :report_only

    def initialize
      @directives = {}
    end

    def report_only?
      @report_only
    end

    def valid_directive?(directive)
      DIRECTIVES.include?(kebab_case(directive))
    end

    # Handles directive methods, such as #script_src and #style_src.
    # Can be called multiple times to add additional sources.
    def method_missing(directive_sym, *args)
      directive = directive_sym.to_s.downcase
      @directives[directive] ||= []
      @directives[directive] += args.flatten.compact.map(&:to_s)
      @directives[directive]
    end

    def respond_to_missing?(directive, *)
      valid_directive?(directive) || super
    end

    # Converts sources from our Ruby DSL (camelcase) into proper Content-Security-Policy sources.
    # (kebab-case, trailing colon, wrapped in single quotes, etc.) A few examples:
    # data => data:
    # http => http:
    # self => 'self'
    # unsafe_eval => 'unsafe-eval'
    # https://example.com => https://example.com
    def csp_source(dsl_source)
      return "#{dsl_source}:" if SCHEME_SOURCES.include?(dsl_source)

      kebab_source = kebab_case(dsl_source)
      return "'#{kebab_source}'" if QUOTED_SOURCES.include?(kebab_source)
      return "'#{dsl_source}'" if dsl_source.start_with?("nonce-") ||
                                  dsl_source.start_with?("sha256-")

      dsl_source
    end

    def to_s
      directive_strings = @directives.uniq.sort.map do |directive, dsl_sources|
        [
          kebab_case(directive),
          dsl_sources.map { |source| csp_source(source) }.join(" ")
        ].join(" ")
      end
      directive_strings << "report-uri #{report_uri}" if report_uri.present?
      directive_strings << ""
      directive_strings.join("; ").strip
    end

    def header_name
      report_only? ? "Content-Security-Policy-Report-Only" : "Content-Security-Policy"
    end

    def to_h
      header_value = to_s
      return {} if header_value.blank?

      { header_name => header_value }
    end

    private

    def kebab_case(str)
      str.to_s.downcase.tr("_", "-")
    end
  end
end
