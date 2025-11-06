# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lingvanex::Client do
  let(:api_key) { 'test_api_key_123' }
  let(:client) { described_class.new(api_key: api_key) }
  let(:base_url) { 'https://api-b2b.backenster.com/b1/api/v3' }

  describe '#initialize' do
    it 'creates a client with api_key' do
      expect(client.configuration.api_key).to eq(api_key)
    end

    it 'accepts configuration block' do
      custom_client = described_class.new(api_key: api_key) do |config|
        config.timeout = 60
        config.platform = 'custom'
      end

      expect(custom_client.configuration.timeout).to eq(60)
      expect(custom_client.configuration.platform).to eq('custom')
    end

    it 'raises error when api_key is missing' do
      expect do
        described_class.new
      end.to raise_error(Lingvanex::ConfigurationError)
    end
  end

  describe '#translate' do
    let(:translate_url) { "#{base_url}/translate" }
    let(:translation_response) do
      {
        'result' => 'Hola mundo',
        'from' => 'en_GB',
        'to' => 'es_ES'
      }
    end

    before do
      stub_request(:post, translate_url)
        .with(
          body: hash_including(platform: 'api', to: 'es_ES'),
          headers: {
            'Authorization' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(status: 200, body: translation_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'translates text successfully' do
      result = client.translate('Hello world', to: 'es_ES')
      expect(result['result']).to eq('Hola mundo')
    end

    it 'includes from parameter when provided' do
      stub_request(:post, translate_url)
        .with(body: hash_including(from: 'en_GB'))
        .to_return(status: 200, body: translation_response.to_json)

      client.translate('Hello', to: 'es_ES', from: 'en_GB')

      expect(WebMock).to have_requested(:post, translate_url)
        .with(body: hash_including(from: 'en_GB'))
    end

    it 'includes translate_mode when provided' do
      stub_request(:post, translate_url)
        .with(body: hash_including(translateMode: 'html'))
        .to_return(status: 200, body: translation_response.to_json)

      client.translate('<p>Hello</p>', to: 'es_ES', translate_mode: 'html')

      expect(WebMock).to have_requested(:post, translate_url)
        .with(body: hash_including(translateMode: 'html'))
    end

    it 'includes enableTransliteration when true' do
      stub_request(:post, translate_url)
        .with(body: hash_including(enableTransliteration: true))
        .to_return(status: 200, body: translation_response.to_json)

      client.translate('Hello', to: 'es_ES', enable_transliteration: true)

      expect(WebMock).to have_requested(:post, translate_url)
        .with(body: hash_including(enableTransliteration: true))
    end

    it 'handles array of texts' do
      texts = %w[Hello World]
      stub_request(:post, translate_url)
        .with(body: hash_including(data: texts))
        .to_return(status: 200, body: translation_response.to_json)

      client.translate(texts, to: 'es_ES')

      expect(WebMock).to have_requested(:post, translate_url)
        .with(body: hash_including(data: texts))
    end

    context 'when API returns 401' do
      before do
        stub_request(:post, translate_url)
          .to_return(status: 401, body: 'Unauthorized')
      end

      it 'raises AuthenticationError' do
        expect do
          client.translate('Hello', to: 'es_ES')
        end.to raise_error(Lingvanex::AuthenticationError, 'Authentication failed')
      end
    end

    context 'when API returns 429' do
      before do
        stub_request(:post, translate_url)
          .to_return(status: 429, body: 'Rate limit exceeded')
      end

      it 'raises RateLimitError' do
        expect do
          client.translate('Hello', to: 'es_ES')
        end.to raise_error(Lingvanex::RateLimitError, 'Rate limit exceeded')
      end
    end

    context 'when API returns 400' do
      before do
        stub_request(:post, translate_url)
          .to_return(status: 400, body: 'Bad request')
      end

      it 'raises InvalidRequestError' do
        expect do
          client.translate('Hello', to: 'es_ES')
        end.to raise_error(Lingvanex::InvalidRequestError, /Invalid request/)
      end
    end

    context 'when API returns 500' do
      before do
        stub_request(:post, translate_url)
          .to_return(status: 500, body: 'Internal server error')
      end

      it 'raises APIError' do
        expect do
          client.translate('Hello', to: 'es_ES')
        end.to raise_error(Lingvanex::APIError, /API error/)
      end
    end

    context 'when API returns invalid JSON' do
      before do
        stub_request(:post, translate_url)
          .to_return(status: 200, body: 'not valid json{', headers: { 'Content-Type' => 'application/json' })
      end

      it 'raises APIError with JSON parse error message' do
        expect do
          client.translate('Hello', to: 'es_ES')
        end.to raise_error(Lingvanex::APIError, /Invalid JSON response/)
      end
    end
  end

  describe '#get_languages' do
    let(:languages_url) { "#{base_url}/getLanguages?platform=api&code=en_GB" }
    let(:languages_response) do
      {
        'result' => [
          { 'full_code' => 'en_GB', 'name' => 'English' },
          { 'full_code' => 'es_ES', 'name' => 'Spanish' }
        ]
      }
    end

    before do
      stub_request(:get, languages_url)
        .with(
          headers: {
            'Authorization' => api_key,
            'Content-Type' => 'application/json'
          }
        )
        .to_return(status: 200, body: languages_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'fetches available languages' do
      result = client.get_languages
      expect(result['result']).to be_an(Array)
      expect(result['result'].first['full_code']).to eq('en_GB')
    end

    it 'accepts custom language code' do
      custom_url = "#{base_url}/getLanguages?platform=api&code=de_DE"
      stub_request(:get, custom_url)
        .to_return(status: 200, body: languages_response.to_json)

      client.get_languages(code: 'de_DE')

      expect(WebMock).to have_requested(:get, custom_url)
    end
  end
end
