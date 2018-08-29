require 'bollard/signature'
require 'bollard/post'

module Bollard
  def self.secure_post(url, payload, signing_secret, extra_headers: {}, auth_header: 'Bollard-Signature')
    post = Post.new(url, payload, signing_secret, extra_headers, auth_header)
    post.perform
  end


  def self.verify_post(payload, header, signing_secret, tolerance: nil)
    Signature.verify(payload, header, signing_secret, tolerance: tolerance)
  end
end
