require 'spec_helper'

RSpec.describe Bollard do
  describe ".secure_post" do
    let(:post) { instance_double(Bollard::Post, perform: true) }

    before do
      allow(Bollard::Post).to receive(:new).and_return(post)
    end

    it "delegates everything to Post" do
      Bollard.secure_post("https://url.com", "{}", "secrets", extra_headers: { header_1: "1" }, auth_header: "Authorization")
      expect(Bollard::Post).to have_received(:new).with("https://url.com", "{}", "secrets", extra_headers: { header_1: "1" }, auth_header: "Authorization")
      expect(post).to have_received(:perform)
    end

    it "provides defaults for extra_headers" do
      Bollard.secure_post("https://url.com", "{}", "secrets", auth_header: "Authorization")
      expect(Bollard::Post).to have_received(:new).with("https://url.com", "{}", "secrets", extra_headers: {}, auth_header: "Authorization")
    end

    it "provides defaults for auth_header" do
      Bollard.secure_post("https://url.com", "{}", "secrets", extra_headers: { header_1: "1" })
      expect(Bollard::Post).to have_received(:new).with("https://url.com", "{}", "secrets", extra_headers: { header_1: "1" }, auth_header: "Bollard-Signature")
    end
  end

  describe ".verify_post" do
    before do
      allow(Bollard::Signature).to receive(:verify_header)
    end

    it "delegates everything to Signature" do
      Bollard.verify_post("{}", "abc123", "secrets", tolerance: 100)

      expect(Bollard::Signature).to have_received(:verify_header).with("{}", "abc123", "secrets", tolerance: 100)
    end

    it "provides a default for tolerance" do
      Bollard.verify_post("{}", "abc123", "secrets")

      expect(Bollard::Signature).to have_received(:verify_header).with("{}", "abc123", "secrets", tolerance: nil)
    end
  end
end
