require "spec_helper"
require 'digest'

RSpec.describe Bollard::Signature do
  describe ".calculate_signature" do
    it "returns a signature" do
      expect(Bollard::Signature.calculate_signature("Some test data")).to be_present
    end

    it "returns an SHA256 hex digest of the given data" do
      expected_digest = "6e6ff23ec852afdf8fc294da163a55b2d246ec45b9659d290dc8871aea1502c0"
      expect(Bollard::Signature.calculate_signature("Some test data")).to eq expected_digest
    end
  end

  describe "#match?" do
    it "returns true if the given signature matches the given payload" do
      expected_digest = "6e6ff23ec852afdf8fc294da163a55b2d246ec45b9659d290dc8871aea1502c0"
      expect(Bollard::Signature.new(expected_digest).match?("Some test data")).to be true
    end

    it "returns false if the given signature doesn't match the given payload" do
      expected_digest = "6e6ff23ec852afdf8fc294da163a55b2d246ec45b9659d290dc8871aea1502c0"
      expect(Bollard::Signature.new(expected_digest).match?("Some other test data")).to be false
    end
  end
end
