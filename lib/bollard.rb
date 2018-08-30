require 'bollard/version'
require 'bollard/token'
require 'bollard/signature'

require 'securerandom'

class Bollard
  def self.generate_secret(length: 32)
    SecureRandom.hex((length / 2.0).ceil)[0...length]
  end


  def initialize(signing_secret)
    @signing_secret = signing_secret
  end


  def generate_token(payload, **args)
    Token.generate(payload, signing_secret, **args)
  end


  def verify_payload(payload, token, **args)
    Token.new(token, signing_secret).verify_payload(payload, **args)
  end


  private

  attr_reader :signing_secret
end
