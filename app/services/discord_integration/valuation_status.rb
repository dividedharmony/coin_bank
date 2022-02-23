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

    def initialize
      @accounts = CoinbaseIntegration::Query::Accounts
        .new(STDOUT)
        .retrieve
        .value!
    end

    def formatted_message
      <<~TEXT
        Report date: _#{Time.now.strftime("%H:%M %B %d, %Y")}_
        #{formatted_stats}
      TEXT
    end

    private

    attr_reader :accounts

    def formatted_stats
      payloads.map do |payload|
        percent = payload[:percent_of_target].round(3)
        actual = payload[:actual_value].round(3)
        target = payload[:target_value].round(3)
        alert = percent > 0.8 ? '**ALERT**' : '.....'
        "#{alert} #{payload[:symbol]} - #{percent}   (#{actual}/#{target})"
      end.join("\n")
    end

    def payloads
      CURRENCIES_AND_TARGET_VALUATIONS.map(&method(:compile_payload))
    end

    def compile_payload(currency_symbol, target_value)
      raw_account = accounts.fetch(currency_symbol)
      account_balance = BigDecimal(raw_account.fetch('balance').fetch('amount'))
      dollar_value = query_usd_value(currency_symbol)
      actual_value = dollar_value * account_balance

      # @return hash
      {
        symbol: currency_symbol,
        dollar_value: dollar_value,
        account_balance: account_balance,
        actual_value: actual_value,
        target_value: target_value,
        percent_of_target: actual_value / target_value
      }
    end

    def query_usd_value(currency_symbol)
      response = CoinbaseIntegration::Client.new.exchange_rates(currency_symbol).value!
      BigDecimal(response.data.fetch('rates').fetch('USD'))
    end
  end
end
