# frozen_string_literal: true

require 'json'
require 'faraday'

module CoinbaseIntegration
  class Client
    COINBASE_URI = "https://api.coinbase.com"

    include Results::Methods

    def accounts(starting_after_uuid: nil)
      request("/v2/accounts", params: { starting_after: starting_after_uuid })
    end

    def exchange_rates(currency_symbol)
      request('/v2/exchange-rates', params: { currency: currency_symbol })
    end

    def transactions(account_uuid, starting_after_uuid: nil)
      request(
        "/v2/accounts/#{account_uuid}/transactions",
        params: { starting_after: starting_after_uuid }
      )
    end

    def buys(account_uuid, starting_after_uuid: nil)
      request(
        "/v2/accounts/#{account_uuid}/buys",
        params: { starting_after: starting_after_uuid }
      )
    end

    def trades
      request("/v2/trades")
    end

    # private

    attr_reader :base_uri

    def request(simple_path, params: {})
      request_path = path_with_params(simple_path, params)
      headers = ApiHeaders.new(
        request_path: request_path,
        body: nil
      ).to_h
      response = Faraday.get(
        uri(request_path),
        nil,
        headers
      )
      parsed_body = JSON.parse(response.body)
      resource = Resource.new(parsed_body)
      if response.success?
        succeed!(resource)
      else
        fail!(resource.error_message)
      end
    end

    private

    def uri(request_path)
      "#{COINBASE_URI}#{request_path}"
    end

    def path_with_params(path, params)
      compacted_params = params.compact
      return path if compacted_params.empty?
      stringified_params = compacted_params.map { |key, value| "#{key}=#{value}" }.join(",")
      "#{path}?#{stringified_params}"
    end
  end
end
