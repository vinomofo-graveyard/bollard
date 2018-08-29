require 'byebug'
require 'active_support/testing/time_helpers'

require 'webmock/rspec'
require File.expand_path('../../lib/bollard', __FILE__)
Dir[File.expand_path('../spec/support/**/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.order = 'random'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include ActiveSupport::Testing::TimeHelpers
end
