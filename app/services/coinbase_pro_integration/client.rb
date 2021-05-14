# frozen_string_literal: true

require 'json'
require 'dry/monads'
require 'faraday'

module CoinbaseProIntegration
  class Client
    COINBASE_PRO_URI = "https://api.pro.coinbase.com"

    include Dry::Monads[:result]

    def transfers
      request("/transfers", nil)
    end

    def accounts
      request("/accounts", nil)
    end

    def profiles
      request("/profiles", nil)
    end

    private

    attr_reader :base_uri

    def request(request_path, body)
      headers = ApiObject.new(
        request_path: request_path,
        body: body
      ).headers
      response = Faraday.get(
        uri(request_path),
        body,
        headers
      )
      parsed_body = JSON.parse(response.body)
      if response.success?
        Success(parsed_body)
      else
        Failure(parsed_body)
      end
    end

    def uri(request_path)
      "#{COINBASE_PRO_URI}#{request_path}"
    end
  end
end
