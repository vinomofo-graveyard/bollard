require "spec_helper"
require 'digest'

RSpec.describe Bollard::Signature do
  describe ".generate" do
    let(:jwt) { Bollard::Signature.generate("Some data", "super-secret") }
    let(:jwt_payload) { JWT.decode(jwt, "super-secret", true)[0] }

    it "generates a valid JWT for the given payload" do
      expect { JWT.decode(jwt, "super-secret", true) }.not_to raise_error
    end

    it "adds an issued-at field" do
      travel_to(Time.now) do
        expect(jwt_payload["iat"]).to eq Time.now.to_i
      end
    end

    it "adds an expires-at field" do
      travel_to(Time.now) do
        expect(jwt_payload["exp"]).to eq(Time.now.to_i + 600)
      end
    end

    context "when given a ttl" do
      let(:jwt) { Bollard::Signature.generate("Some data", "super-secret", ttl: 100) }

      it "sets the expires-at field using the configurable ttl" do
        travel_to(Time.now) do
          expect(jwt_payload["exp"]).to eq(Time.now.to_i + 100)
        end
      end
    end

    it "adds a hash of the data" do
      expect(jwt_payload["sig_v1"]).to eq(Digest::SHA256.hexdigest("Some data"))
    end

    it "signs the jwt with the secret so it can be verified" do
      expect { JWT.decode(jwt, "not-the-same-secret", true) }.to raise_error(JWT::VerificationError, "Signature verification raised")
    end
  end

  describe ".verify" do
    it "verifies the signing secret matches the given secret" do
      jwt = Bollard::Signature.generate("Some data", "super-secret")
      expect { Bollard::Signature.verify("Some data", jwt, "different-super-secret") }.to raise_error(Bollard::SignatureVerificationError, "Signature verification raised")
    end

    it "verifies the payload matches the given hash" do
      jwt = Bollard::Signature.generate("Some data", "super-secret")
      expect { Bollard::Signature.verify("Some different data", jwt, "super-secret") }.to raise_error(Bollard::SignatureVerificationError, "Hash mismatch for payload")
    end

    it "verifies the format of the token" do
      jwt = JWT.encode({ sig_v2: Digest::SHA256.hexdigest("Some data") }, "super-secret", 'HS256')

      expect { Bollard::Signature.verify("Some data", jwt, "super-secret") }.to raise_error(Bollard::SignatureVerificationError, "No hash found with expected algorithm #{Bollard::Signature::EXPECTED_ALGORITHM}")
    end

    it "ensures that the jwt hasn't expired" do
      jwt = Bollard::Signature.generate("Some data", "super-secret")
      travel_to(Time.now + 1200) do
        expect { Bollard::Signature.verify("Some data", jwt, "super-secret") }.to raise_error(Bollard::SignatureVerificationError, "Signature has expired")
      end
    end

    it "allows leeway for the expiry if set" do
      jwt = Bollard::Signature.generate("Some data", "super-secret")
      travel_to(Time.now + 1200) do
        expect { Bollard::Signature.verify("Some data", jwt, "super-secret", tolerance: 1200) }.not_to raise_error
      end
    end
  end
end
