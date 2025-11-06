# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'

  add_group 'Client', 'lib/lingvanex/client.rb'
  add_group 'Configuration', 'lib/lingvanex/configuration.rb'
  add_group 'Errors', 'lib/lingvanex/errors.rb'

  minimum_coverage 90
end

require 'bundler/setup'
require 'lingvanex'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset configuration before each test
  config.before do
    Lingvanex.reset_configuration!
  end

  # Disable external HTTP requests
  WebMock.disable_net_connect!(allow_localhost: true)
end
