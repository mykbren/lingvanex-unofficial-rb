# frozen_string_literal: true

module Lingvanex
  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :platform

    def initialize
      @api_key = nil
      @base_url = 'https://api-b2b.backenster.com/b1/api/v3' # Official Lingvanex API endpoint
      @timeout = 30
      @platform = 'api'
    end

    def validate!
      raise ConfigurationError, 'API key is required' if api_key.nil? || api_key.empty?
    end
  end
end
