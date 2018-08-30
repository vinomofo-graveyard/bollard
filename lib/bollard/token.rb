require 'jwt'

class Bollard
  SignatureVerificationError = Class.new(RuntimeError)

  class Token

    # Generate the token header for a given payload.
    # The token becomes invalid after `ttl` seconds.
    #
    # Returns a JWT with an iat, exp, and signature data
    def self.generate(payload, signing_secret, ttl: 600)
      iat = Time.now.to_i
      signature = Signature.calculate_signature(payload)
      jwt_payload = { iat: iat, exp: iat + ttl, Signature::EXPECTED_ALGORITHM => signature }
      JWT.encode(jwt_payload, signing_secret, 'HS256')
    end


    def initialize(token, signing_secret)
      @token = token
      @signing_secret = signing_secret
    end


    # Verifies the token header for a given payload.
    #
    # Raises a SignatureVerificationError in the following cases:
    # - the header does not match the expected format
    # - no hash found with the expected algorithm
    # - hash doesn't match the expected hash
    #
    # Returns true otherwise
    def verify_payload(payload, tolerance: nil)
      token_data, header = decode_token(tolerance)
      signature = extract_signature(token_data)
      verify_data(signature, payload)

      true
    end


    private

    attr_reader :token, :signing_secret

    def decode_token(tolerance)
      JWT.decode(token, signing_secret, true, { exp_leeway: tolerance })
    rescue JWT::DecodeError => e
      raise SignatureVerificationError.new(e.message)
    end

    def extract_signature(token_data)
      signature = token_data[Signature::EXPECTED_ALGORITHM]
      return Signature.new(signature) unless signature.blank?
      raise SignatureVerificationError.new("No signature found with expected algorithm #{Signature::EXPECTED_ALGORITHM}")
    end

    def verify_data(signature, payload)
      return true if signature.match?(payload)
      raise SignatureVerificationError.new("Hash mismatch for payload")
    end
  end
end
