# frozen_string_literal: true

require 'base64'
require 'openssl'
require 'json'

# Modified from CoinBase docs:
# https://docs.pro.coinbase.com/?ruby#creating-a-request
module CoinbaseIntegration
  class ApiObject
    # All API calls should be made with a CB-VERSION
    # header which guarantees that your call is using
    # the correct API version. Version is passed in as
    # a date (UTC) of the implementation in YYYY-MM-DD format.
    CB_VERSION = "2021-03-31"

    def initialize(request_path:, body:, time: nil, method: 'GET')
      @key = ENV.fetch("COINBASE_API_KEY")
      @secret = ENV.fetch("COINBASE_API_SECRET")
      @request_path = request_path
      @body_json = jsonify(body)
      @timestamp = (time || Time.now).to_i
      @method = method
    end

    def headers
      {
        "CB-ACCESS-KEY" => key,
        "CB-ACCESS-SIGN" => signature,
        "CB-ACCESS-TIMESTAMP" => timestamp.to_s,
        "CB-VERSION" => CB_VERSION,
        "Content-Type" => "application/json"
      }
    end

    private

    attr_reader :key, :secret, :request_path, :body_json, :timestamp, :method

    def signature
      signature_content = "#{timestamp}#{method}#{request_path}#{body_json}"
      OpenSSL::HMAC.hexdigest('sha256', secret, signature_content)
    end

    def jsonify(body)
      if body.nil?
        ''
      elsif body.is_a?(Hash)
        body.to_json
      else
        body
      end
    end
  end
end
