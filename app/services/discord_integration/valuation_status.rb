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
      @payloads = []
      compile_payloads
    end

    def formatted_message
      <<~TEXT
        Report date: _#{Time.now.strftime("%H:%M %B %d, %Y")}_
        #{formatted_stats}
      TEXT
    end

    private

    attr_reader :accounts, :payloads

    def formatted_stats
      payloads.map do |payload|
        percent = payload[:percent_of_target].round(3)
        actual = payload[:actual_value].round(3)
        target = payload[:target_value].round(3)
        alert = percent > 0.8 ? '**ALERT**' : '.....'
        "#{alert} #{payload[:symbol]} - #{percent}   (#{actual}/#{target})"
      end.join("\n")
    end

    def compile_payloads
      CURRENCIES_AND_TARGET_VALUATIONS.each do |sym, target_val|
        currency = CoinBank::Currency.find_by!(symbol: sym)
        usd_val = usd_value(currency)
        account_bal = account_balance(currency)
        actual_value = usd_val * account_bal
        payloads << {
          name: currency.name,
          symbol: currency.symbol,
          dollar_value: usd_val,
          account_balance: account_bal,
          actual_value: actual_value,
          target_value: target_val,
          percent_of_target: actual_value / target_val
        }
      end
    end

    def account_balance(currency)
      raw_account = accounts[currency.symbol]
      BigDecimal(raw_account.fetch('balance').fetch('amount'))
    end

    def usd_value(currency)
      response = CoinbaseIntegration::Client.new.exchange_rates(currency.symbol).value!
      BigDecimal(response.data.fetch('rates').fetch('USD'))
    end
  end
end
