# frozen_string_literal: true

require_relative 'lingvanex/version'
require_relative 'lingvanex/errors'
require_relative 'lingvanex/configuration'
require_relative 'lingvanex/client'

module Lingvanex
  class << self
    attr_writer :configuration

    def configure
      yield(configuration)
      configuration.validate!
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def client(api_key: nil, &block)
      if api_key || block_given?
        Client.new(api_key: api_key, &block)
      else
        configuration.validate!
        Client.new(api_key: configuration.api_key)
      end
    end
  end
end
