# frozen_string_literal: true

module Accounting
  class Holdings
    def initialize
      @currencies = CoinBank::Currency.unstable.to_a
      @value_per_currency = {}
    end

    def valuations
      return value_per_currency if value_per_currency.any?
      currencies.each do |currency|
        value_per_currency[currency.symbol] = Valuation.new(currency).to_d
      end
      value_per_currency
    end

    private

    attr_reader :currencies, :value_per_currency
  end
end
