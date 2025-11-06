# frozen_string_literal: true

module Lingvanex
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class APIError < Error
    attr_reader :status_code, :response_body

    def initialize(message, status_code: nil, response_body: nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  class AuthenticationError < APIError; end

  class RateLimitError < APIError; end

  class InvalidRequestError < APIError; end
end
