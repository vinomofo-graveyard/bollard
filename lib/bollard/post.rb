require 'rest-client'

module Bollard
  PostError = Class.new(RuntimeError)

  class Post
    def initialize(url, payload, signing_secret, extra_headers, auth_header)
      @url = url
      @payload = payload
      @signing_secret = signing_secret
      @auth_header = auth_header
      @extra_headers = extra_headers
    end

    def perform
      RestClient.post(@url, @payload, headers)
    rescue RestClient::ExceptionWithResponse => e
      raise PostError.new(e.response.body)
    rescue RestClient::Exception => e
      raise PostError.new(e.message)
    end

    private

    def headers
      @extra_headers.merge({ @auth_header => signature })
    end

    def signature
      Signature.generate(@payload, @signing_secret)
    end
  end
end