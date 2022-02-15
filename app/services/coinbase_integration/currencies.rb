# frozen_string_literal: true

module CoinbaseIntegration
  class Currencies
    include Results::Methods

    def initialize
      @stored_currencies = {}
    end

    def fetch(currency_symbol)
      get_currency(currency_symbol)
    end

    def [](currency_symbol)
      get_currency(currency_symbol).or { create_currency(currency_symbol) }
    end

    private

    attr_reader :stored_currencies

    def get_currency(currency_symbol)
      return stored_currencies[currency_symbol] if stored_currencies.key?(currency_symbol)
      currency = CoinBank::Currency.find_by(symbol: currency_symbol)
      if currency.nil?
        fail!("Could not find currency with symbol '#{currency_symbol}'.")
      else
        stored_currencies[currency_symbol] = currency
        succeed!(currency)
      end
    end

    def create_currency(currency_symbol)
      CoinBank::CreateCurrency.({
        coin_bank_currency: {
          symbol: currency_symbol
        }
      }).bind do |currency|
        stored_currencies[currency_symbol] = currency
        succeed!(currency)
      end
    end
  end
end
