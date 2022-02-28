# frozen_string_literal: true

require 'discordrb'

module DiscordIntegration
  class ValuationStatus
    CURRENCIES_AND_TARGET_VALUATIONS = {
      "BCH" => {
        target_value: 685.0,
        alert_threshold: 0.85
      },
      "ETC" => {
        target_value: 325.0,
        alert_threshold: 0.55
      },
      "MKR" => {
        target_value: 299.0,
        alert_threshold: 0.5
      },
      "COMP" => {
        target_value: 276.68,
        alert_threshold: 0.5
      },
      "LINK" => {
        target_value: 398.59,
        alert_threshold: 0.62
      },
      "LTC" => {
        target_value: 559.16,
        alert_threshold: 0.75
      },
      "ALGO" => {
        target_value: 494.61,
        alert_threshold: 0.7
      }
    }.freeze

    class << self
      def all
        raw_accounts = query_accounts
        CURRENCIES_AND_TARGET_VALUATIONS.map do |currency_symbol, target_data|
          new(
            raw_accounts.fetch(currency_symbol),
            currency_symbol,
            target_data[:target_value],
            target_data[:alert_threshold]
          )
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

    def initialize(account, currency_symbol, target_value, alert_threshold)
      @account = account
      @currency_symbol = currency_symbol
      @target_value = target_value
      @alert_threshold = alert_threshold
    end

    attr_reader :account, :currency_symbol, :target_value, :alert_threshold

    def dollar_value
      @dollar_value ||= BigDecimal(exchange_rate_data.fetch('rates').fetch('USD'))
    end

    def account_balance
      @account_balance ||= BigDecimal(account.fetch('balance').fetch('amount'))
    end

    def actual_value
      @actual_value ||= (dollar_value * account_balance).round(3)
    end

    def percent_of_target
      @percent_of_target ||= (actual_value / target_value).round(3)
    end

    def alert?
      percent_of_target >= alert_threshold
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
