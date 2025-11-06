# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lingvanex::Configuration do
  subject(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default values' do
      expect(config.api_key).to be_nil
      expect(config.base_url).to eq('https://api-b2b.backenster.com/b1/api/v3')
      expect(config.timeout).to eq(30)
      expect(config.platform).to eq('api')
    end
  end

  describe '#validate!' do
    context 'when api_key is nil' do
      it 'raises ConfigurationError' do
        config.api_key = nil
        expect { config.validate! }.to raise_error(Lingvanex::ConfigurationError, 'API key is required')
      end
    end

    context 'when api_key is empty' do
      it 'raises ConfigurationError' do
        config.api_key = ''
        expect { config.validate! }.to raise_error(Lingvanex::ConfigurationError, 'API key is required')
      end
    end

    context 'when api_key is present' do
      it 'does not raise error' do
        config.api_key = 'valid_key'
        expect { config.validate! }.not_to raise_error
      end
    end
  end

  describe 'attribute accessors' do
    it 'allows setting and getting api_key' do
      config.api_key = 'my_key'
      expect(config.api_key).to eq('my_key')
    end

    it 'allows setting and getting base_url' do
      config.base_url = 'https://custom.url'
      expect(config.base_url).to eq('https://custom.url')
    end

    it 'allows setting and getting timeout' do
      config.timeout = 60
      expect(config.timeout).to eq(60)
    end

    it 'allows setting and getting platform' do
      config.platform = 'custom'
      expect(config.platform).to eq('custom')
    end
  end
end
