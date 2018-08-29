require 'spec_helper'

RSpec.describe Bollard::Post do
  it "posts the payload to the given URL" do
    stub_request(:post, "https://test.localhost/")

    post = Bollard::Post.new("https://test.localhost/", "{}", "secret", {}, "Bollard-Signature")
    post.perform

    expect(WebMock).to have_requested(:post, "https://test.localhost").with(body: "{}")
  end

  it "adds the correct signature header to the request" do
    allow(Bollard::Signature).to receive(:generate).and_return("valid_signature")
    stub_request(:post, "https://test.localhost/")

    post = Bollard::Post.new("https://test.localhost/", "{}", "secret", {}, "Bollard-Signature")
    post.perform

    expect(WebMock).to have_requested(:post, "https://test.localhost")
      .with(headers: { "Bollard-Signature" => "valid_signature" })
  end

  it "adds extra headers to the request" do
    stub_request(:post, "https://test.localhost/")

    post = Bollard::Post.new("https://test.localhost/", "{}", "secret", { content_type: :json, accept: :json }, "Bollard-Signature")
    post.perform

    expect(WebMock).to have_requested(:post, "https://test.localhost")
      .with(headers: { content_type: 'application/json', accept: 'application/json' })
  end
end
