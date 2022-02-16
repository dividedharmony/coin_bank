# frozen_string_literal: true

module CoinbaseIntegration
  class Resource
    include Enumerable

    def initialize(body)
      @body = body
    end

    attr_reader :body
    delegate :each, :[], :slice, to: :data

    def data
      body["data"]
    end

    def pagination
      body.fetch('pagination', {})
    end

    def error_message
      errors = body["errors"]
      return nil if errors.empty?

      messages = errors.map { |e| e['message'] }
      messages.join("\n")
    end
  end
end
