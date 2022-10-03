# frozen_string_literal: true

RSpec.describe BetterContentSecurityPolicy::ContentSecurityPolicy do
  let(:csp) { described_class.new }

  it "has no default policy" do
    expect(csp.to_s).to eq("")
  end

  context "with some basic defaults" do
    before do
      csp.default_src :self
      csp.script_src :self
      csp.style_src :self
    end

    it "generates a headers string" do
      expect(csp.to_s).to eq "default-src 'self'; script-src 'self'; style-src 'self';"
    end

    it "generates a headers hash" do
      expect(csp.to_h).to eq(
        "Content-Security-Policy" => "default-src 'self'; script-src 'self'; style-src 'self';"
      )
    end

    it "generates a blocking policy" do
      csp.report_uri = "/csp-report"
      expect(csp.to_h).to eq(
        {
          "Content-Security-Policy" =>
            "default-src 'self'; script-src 'self'; style-src 'self'; report-uri /csp-report;"
        }
      )
    end

    it "generates a report-only policy" do
      csp.report_only = true
      csp.report_uri = "/csp-report"
      expect(csp.to_h).to eq(
        {
          "Content-Security-Policy-Report-Only" =>
            "default-src 'self'; script-src 'self'; style-src 'self'; report-uri /csp-report;"
        }
      )
    end

    it "generates the correct sources without any duplicates" do
      csp.default_src :self, :unsafe_eval
      csp.script_src :self, :https, "https://example.com"
      csp.style_src :none
      csp.report_uri = "https://example.com/csp-report"
      expect(csp.to_s).to eq(
        "default-src 'self' 'self' 'unsafe-eval'; script-src 'self' 'self' https: https://example.com; " \
        "style-src 'self' 'none'; report-uri https://example.com/csp-report;"
      )
    end
  end
end
