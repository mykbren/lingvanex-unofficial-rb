# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'openssl'

module Lingvanex
  class Client
    attr_reader :configuration

    def initialize(api_key: nil)
      @configuration = Configuration.new
      @configuration.api_key = api_key if api_key
      yield(@configuration) if block_given?
      @configuration.validate!
    end

    def translate(text, to:, from: nil, translate_mode: nil, enable_transliteration: false)
      body = {
        platform: configuration.platform,
        to: to,
        data: text
      }
      body[:from] = from if from
      body[:translateMode] = translate_mode if translate_mode
      body[:enableTransliteration] = enable_transliteration if enable_transliteration

      post('/translate', body)
    end

    def get_languages(code: 'en_GB')
      get('/getLanguages', platform: configuration.platform, code: code)
    end

    private

    def get(path, **params)
      uri = URI("#{configuration.base_url}#{path}")
      uri.query = URI.encode_www_form(params) unless params.empty?

      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = configuration.api_key
      request['Content-Type'] = 'application/json'

      execute_request(uri, request)
    end

    def post(path, body)
      uri = URI("#{configuration.base_url}#{path}")

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = configuration.api_key
      request['Content-Type'] = 'application/json'
      request.body = body.to_json

      execute_request(uri, request)
    end

    def execute_request(uri, request)
      response = Net::HTTP.start(
        uri.hostname,
        uri.port,
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        min_version: OpenSSL::SSL::TLS1_2_VERSION,
        read_timeout: configuration.timeout
      ) do |http|
        http.request(request)
      end

      handle_response(response)
    end

    def handle_response(response)
      status = response.code.to_i
      return parse_success_response(response) if (200..299).cover?(status)

      raise_error_for_status(status, response)
    end

    def parse_success_response(response)
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise_api_error("Invalid JSON response: #{e.message}", response)
    end

    def raise_error_for_status(status, response)
      case status
      when 401
        raise_authentication_error(response)
      when 429
        raise_rate_limit_error(response)
      when 400..499
        raise_invalid_request_error(response)
      else
        raise_api_error("API error: #{response.body}", response)
      end
    end

    def raise_authentication_error(response)
      raise AuthenticationError.new('Authentication failed',
                                    status_code: response.code.to_i,
                                    response_body: response.body)
    end

    def raise_rate_limit_error(response)
      raise RateLimitError.new('Rate limit exceeded',
                               status_code: response.code.to_i,
                               response_body: response.body)
    end

    def raise_invalid_request_error(response)
      raise InvalidRequestError.new("Invalid request: #{response.body}",
                                    status_code: response.code.to_i,
                                    response_body: response.body)
    end

    def raise_api_error(message, response)
      raise APIError.new(message,
                         status_code: response.code.to_i,
                         response_body: response.body)
    end
  end
end
