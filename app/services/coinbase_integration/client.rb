# frozen_string_literal: true

require 'json'
require 'faraday'

module CoinbaseIntegration
  class Client
    COINBASE_URI = "https://api.coinbase.com"

    include Results::Methods

    def accounts
      request("/v2/accounts")
    end

    def transactions(account_uuid, starting_after_uuid: nil)
      request(
        "/v2/accounts/#{account_uuid}/transactions",
        params: { starting_after: starting_after_uuid }
      )
    end

    def trades
      request("/v2/trades")
    end

    def trade(trade_uuid)
      request("/v2/trades/#{trade_uuid}")
    end

    # private

    attr_reader :base_uri

    def request(simple_path, params: {})
      request_path = path_with_params(simple_path, params)
      headers = ApiObject.new(
        request_path: request_path,
        body: nil
      ).headers
      response = Faraday.get(
        uri(request_path),
        nil,
        headers
      )
      parsed_body = JSON.parse(response.body)
      if response.success?
        succeed!(
          Resource.new(parsed_body)
        )
      else
        fail!(parsed_body["errors"])
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
