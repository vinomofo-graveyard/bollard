require "spec_helper"

RSpec.describe Bollard do
  describe ".generate_secret" do
    it "generates a secret key" do
      expect(Bollard.generate_secret).to be_present
    end

    it "generates a secret key of the desired length" do
      secret_key = Bollard.generate_secret(length: 67)
      expect(secret_key.length).to be(67)
    end

    it "doesn't generate the same secret key twice" do
      secret_key = Bollard.generate_secret
      other_secret_key = Bollard.generate_secret

      expect(secret_key).not_to eq other_secret_key
    end
  end


  describe "#generate_token" do
    let(:bollard) { Bollard.new("-signing-secret-") }

    it "returns a token" do
      expect(bollard.generate_token("Some test data")).to be_present
    end

    it "generates a new token using Bollard::Token with the given payload" do
      expect(Bollard::Token).to receive(:generate).with("Some test data", "-signing-secret-", {})

      bollard.generate_token("Some test data")
    end

    it "passes on any given arguments" do
      expect(Bollard::Token).to receive(:generate).with("Some test data", "-signing-secret-", ttl: 10)

      bollard.generate_token("Some test data", ttl: 10)
    end
  end


  describe "#verify_payload" do
    let(:bollard) { Bollard.new("-signing-secret-") }

    it "verifies a payload" do
      token = bollard.generate_token("Some test data")
      expect(bollard.verify_payload("Some test data", token)).to eq true
    end

    it "verifies the payload using Bollard::Token" do
      token = instance_double(Bollard::Token, verify_payload: true)
      allow(Bollard::Token).to receive(:new).with("-token-", "-signing-secret-").and_return(token)

      bollard.verify_payload("Some test data", "-token-")

      expect(token).to have_received(:verify_payload).with("Some test data", {})
    end

    it "passes on any given arguments" do
      token = instance_double(Bollard::Token, verify_payload: true)
      allow(Bollard::Token).to receive(:new).with("-token-", "-signing-secret-").and_return(token)

      bollard.verify_payload("Some test data", "-token-", tolerance: 100)

      expect(token).to have_received(:verify_payload).with("Some test data", tolerance: 100)
    end
  end
end
