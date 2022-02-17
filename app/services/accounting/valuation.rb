# frozen_string_literal: true

module Accounting
  class Valuation
    def initialize(currency)
      @currency = currency
    end

    # assumption: 1.0 unit of stable currency equals $1
    def to_d
      value_into_holdings - value_out_of_holdings
    end

    private

    attr_reader :currency

    # value bought into currency
    def value_into_holdings
      value_add_transactions = CoinBank::Transaction
        .includes(:from_currency)
        .where(to_currency: currency)
        .to_a
      value_add_transactions.sum(&:native_amount)
    end

    # value sold out of currency
    def value_out_of_holdings
      value_remove_transactions = CoinBank::Transaction
        .includes(:to_currency)
        .where(from_currency: currency)
        .to_a
      value_remove_transactions.sum(&:native_amount)
    end
  end
end
