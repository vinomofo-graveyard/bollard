require 'digest'
require 'jwt'

module Bollard
  class SignatureVerificationError < RuntimeError
    attr_reader :message, :sig_header, :http_body

    def initialize(message, sig_header, http_body: nil)
      @message = message
      @sig_header = sig_header
      @http_body = http_body
    end
  end

  class Signature
    EXPECTED_ALGORITHM = "sig_v1".freeze


    def self.generate(data, secret, ttl: 600)
      iat = Time.now.to_i
      payload = { iat: iat, exp: iat + ttl, sig_v1: Digest::SHA256.hexdigest(data) }
      JWT.encode(payload, secret, 'HS256')
    end


    # Verifies the signature header for a given payload.
    #
    # Raises a SignatureVerificationError in the following cases:
    # - the header does not match the expected format
    # - no hash found with the expected algorithm
    # - hash doesn't match the expected hash
    #
    # Returns true otherwise
    def self.verify(payload, header, secret, tolerance: nil)
      begin
        decoded_token = JWT.decode(header, secret, true, { exp_leeway: tolerance })
      rescue JWT::DecodeError => e
        raise SignatureVerificationError.new(e.message, header, http_body: payload)
      end

      provided_hash = decoded_token[0][EXPECTED_ALGORITHM]
      if provided_hash.blank?
        raise SignatureVerificationError.new(
          "No hash found with expected algorithm #{EXPECTED_ALGORITHM}",
          header, http_body: payload
        )
      end

      expected_hash = Digest::SHA256.hexdigest(payload)
      unless secure_compare(provided_hash, expected_hash)
        raise SignatureVerificationError.new("Hash mismatch for payload", header, http_body: payload)
      end

      true
    end


    # Constant time string comparison to prevent timing attacks

    # Code borrowed from ActiveSupport
    def self.secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res.zero?
    end
    private_class_method :secure_compare
  end
end
