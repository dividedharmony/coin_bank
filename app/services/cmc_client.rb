# frozen_string_literal: true

require 'json'
require 'dry/monads'
require 'faraday'

class CmcClient
  PRODUCTION_BASE_URI = "https://pro-api.coinmarketcap.com"
  SANDBOX_BASE_URI = "https://sandbox-api.coinmarketcap.com"

  include Dry::Monads[:result]

  def initialize(environment: Rails.env)
    @environment = environment
    @headers = {
      "X-CMC_PRO_API_KEY" => ENV.fetch("COIN_MARKET_CAP_API_KEY")
    }
  end

  def info(symbol:)
    params = {
      "symbol" => symbol.to_s
    }
    response = Faraday.get(
      uri("v1/cryptocurrency/info"),
      params,
      headers
    )
    parsed_body = JSON.parse(response.body)
    if response.success?
      Success(parsed_body['data'][symbol])
    else
      Failure(parsed_body['status']['error_message'])
    end
  end

  private

  attr_reader :environment, :headers

  def uri(path)
    base_uri = environment.test? ? SANDBOX_BASE_URI : PRODUCTION_BASE_URI
    "#{base_uri}/#{path}"
  end
end
