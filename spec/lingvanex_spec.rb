# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lingvanex do
  it 'has a version number' do
    expect(Lingvanex::VERSION).not_to be_nil
  end

  describe '.configure' do
    it 'configures the gem globally' do
      described_class.configure do |config|
        config.api_key = 'test_key'
        config.timeout = 60
      end

      expect(described_class.configuration.api_key).to eq('test_key')
      expect(described_class.configuration.timeout).to eq(60)
    end

    it 'validates configuration' do
      expect do
        described_class.configure do |config|
          config.api_key = nil
        end
      end.to raise_error(Lingvanex::ConfigurationError)
    end
  end

  describe '.client' do
    it 'creates a client with provided api_key' do
      client = described_class.client(api_key: 'test_key')
      expect(client).to be_a(Lingvanex::Client)
      expect(client.configuration.api_key).to eq('test_key')
    end

    it 'creates a client with global configuration' do
      described_class.configure do |config|
        config.api_key = 'global_key'
      end

      client = described_class.client
      expect(client.configuration.api_key).to eq('global_key')
    end

    it 'accepts a configuration block' do
      client = described_class.client do |config|
        config.api_key = 'block_key'
        config.timeout = 45
      end

      expect(client.configuration.api_key).to eq('block_key')
      expect(client.configuration.timeout).to eq(45)
    end
  end

  describe '.reset_configuration!' do
    it 'resets configuration to defaults' do
      described_class.configure do |config|
        config.api_key = 'test_key'
      end

      described_class.reset_configuration!

      expect(described_class.configuration.api_key).to be_nil
    end
  end
end
