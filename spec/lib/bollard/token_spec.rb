require 'spec_helper'

RSpec.describe Bollard::Token do
  describe ".generate" do
    it "returns a valid JWT" do
      token = Bollard::Token.generate("Some test data", "-signing-secret-")
      expect { JWT.decode(token, nil, false) }.not_to raise_error
    end

    it "returns a JWT signed with the given secret" do
      token = Bollard::Token.generate("Some test data", "-signing-secret-")
      expect { JWT.decode(token, "-signing-secret-", true) }.not_to raise_error
    end

    it "returns a JWT with an issued at timestamp (iat)" do
      travel_to(Time.now) do
        token = Bollard::Token.generate("Some test data", "-signing-secret-")
        payload, header = JWT.decode(token, nil, false)
        expect(payload['iat']).to eq Time.now.to_i
      end
    end

    it "returns a JWT with an expiry timestamp (exp)" do
      travel_to(Time.now) do
        token = Bollard::Token.generate("Some test data", "-signing-secret-")
        payload, header = JWT.decode(token, nil, false)
        expect(payload['exp']).to eq Time.now.to_i + 600
      end
    end

    it "returns a JWT with an expiry timestamp (exp) set to the expire after the given TTL" do
      travel_to(Time.now) do
        token = Bollard::Token.generate("Some test data", "-signing-secret-", ttl: 10)
        payload, header = JWT.decode(token, nil, false)
        expect(payload['exp']).to eq Time.now.to_i + 10
      end
    end
  end

  describe "#verify_payload" do
    it "returns true if given a payload that matches the signature from the token" do
      token = Bollard::Token.generate("Some test data", "-signing-secret-")
      expect { Bollard::Token.new(token, "-signing-secret-").verify_payload("Some test data") }.not_to raise_error
    end

    it "raises an error if given a token that wasn't signed with the signing secret" do
      token = Bollard::Token.generate("Some test data", "-signing-secret-")
      expect { Bollard::Token.new(token, "-different-secret-").verify_payload("Some test data") }.to raise_error(
        Bollard::SignatureVerificationError, "Signature verification raised"
      )
    end

    it "raises an error if given a token that has expired" do
      token = Bollard::Token.generate("Some test data", "-signing-secret-")
      travel_to(Time.now + 1000) do
        expect do
          Bollard::Token.new(token, "-signing-secret-").verify_payload("Some test data")
        end.to raise_error(Bollard::SignatureVerificationError, "Signature has expired")
      end
    end

    it "allows some tolerance in the expiry if custom tolerance passed in" do
      token = Bollard::Token.generate("Some test data", "-signing-secret-")
      travel_to(Time.now + 1000) do
        expect do
          Bollard::Token.new(token, "-signing-secret-").verify_payload("Some test data", tolerance: 1000)
        end.not_to raise_error
      end
    end

    it "raises an error if given a token that doesn't contain expected signature information" do
      token = JWT.encode({}, "-signing-secret-")
      expected_error_message = "No signature found with expected algorithm #{Bollard::Signature::EXPECTED_ALGORITHM}"
      expect do
        Bollard::Token.new(token, "-signing-secret-").verify_payload("Some test data")
      end.to raise_error(Bollard::SignatureVerificationError, expected_error_message)
    end

    it "raises an error if given a payload that doesn't match the signature contained in the token" do
      token = Bollard::Token.generate("Some test data", "-signing-secret-")
      expect do
        Bollard::Token.new(token, "-signing-secret-").verify_payload("Some other test data")
      end.to raise_error(Bollard::SignatureVerificationError, "Hash mismatch for payload")
    end
  end
end
