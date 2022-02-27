# frozen_string_literal: true

require 'discordrb'

module DiscordIntegration
  class ValuationStatus
    CURRENCIES_AND_TARGET_VALUATIONS = {
      "BTC"=>1557.8,
      "ETH"=>1865.85,
      "BCH"=>685.0,
      "ETC"=>325.0,
      "MKR"=>299.0,
      "COMP"=>276.68,
      "LINK"=>398.59,
      "LTC"=>559.16,
      "ALGO"=>494.61,
      "ADA"=>348.0
    }.freeze

    class << self
      def all
        raw_accounts = query_accounts
        CURRENCIES_AND_TARGET_VALUATIONS.map do |currency_symbol, target_value|
          new(raw_accounts.fetch(currency_symbol), currency_symbol, target_value)
        end
      end

      private

      def query_accounts
        CoinbaseIntegration::Query::Accounts
          .new(STDOUT)
          .retrieve
          .value!
      end
    end

    def initialize(account, currency_symbol, target_value)
      @account = account
      @currency_symbol = currency_symbol
      @target_value = target_value
    end

    attr_reader :account, :currency_symbol, :target_value

    def dollar_value
      @dollar_value ||= BigDecimal(exchange_rate_data.fetch('rates').fetch('USD'))
    end

    def account_balance
      @account_balance ||= BigDecimal(account.fetch('balance').fetch('amount'))
    end

    def actual_value
      @actual_value ||= dollar_value * account_balance
    end

    def percent_of_target
      actual_value / target_value
    end

    private

    def exchange_rate_data
      CoinbaseIntegration::Client
        .new
        .exchange_rates(currency_symbol)
        .value!
        .data
    end
  end
end
