# frozen_string_literal: true

module CoinbaseIntegration
  class Currencies
    class CouldNotFindOrCreate < StandardError
      def initialize(currency_symbol)
        super("Could not find or create currency with symbol #{currency_symbol.inspect}")
      end
    end

    include Results::Methods

    def initialize(*currency_records)
      @stored_currencies = {}
      currency_records.each do |currency|
        stored_currencies[currency.symbol] = currency
      end
    end

    def fetch(currency_symbol)
      find_or_create.or do
        raise CouldNotFindOrCreate, currency_symbol
      end
    end

    def find_or_create(currency_symbol)
      get_currency(currency_symbol).or { create_currency(currency_symbol) }
    end

    alias_method :[], :find_or_create

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
