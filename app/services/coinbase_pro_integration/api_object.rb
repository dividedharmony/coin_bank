# frozen_string_literal: true

require 'base64'
require 'openssl'
require 'json'

# Modified from CoinBase docs:
# https://docs.pro.coinbase.com/?ruby#creating-a-request
module CoinbaseProIntegration
  class ApiObject
    def initialize(request_path:, body:, time: nil, method: 'GET')
      @key = ENV.fetch("COINBASE_PRO_API_KEY")
      @secret = ENV.fetch("COINBASE_PRO_API_SECRET")
      @passphrase = ENV.fetch("COINBASE_PRO_API_PASSPHRASE")
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
        "CB-ACCESS-PASSPHRASE" => passphrase,
        "Content-Type" => "application/json"
      }
    end

    private

    attr_reader :key, :secret, :passphrase, :request_path, :body_json, :timestamp, :method

    def signature
      signature_content = "#{timestamp}#{method}#{request_path}#{body_json}"

      # create a sha256 hmac with the secret
      base64_secret = Base64.decode64(secret)
      digested_content  = OpenSSL::HMAC.digest('sha256', base64_secret, signature_content)
      Base64.strict_encode64(digested_content)
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
