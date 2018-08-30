require 'digest'

class Bollard
  class Signature
    EXPECTED_ALGORITHM = "sig_v1".freeze

    def self.calculate_signature(payload)
      Digest::SHA256.hexdigest(payload)
    end


    def initialize(signature)
      @signature = signature
    end


    def match?(payload)
      secure_compare(signature, self.class.calculate_signature(payload))
    end


    private

    attr_reader :signature

    # Constant time string comparison to prevent timing attacks

    # Code borrowed from ActiveSupport
    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res.zero?
    end
  end
end
