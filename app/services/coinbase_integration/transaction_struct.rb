# frozen_string_literal: true

module CoinbaseIntegration
  class TransactionStruct
    def initialize(raw_transaction)
      @raw_transaction = raw_transaction
      @type = raw_transaction.fetch('type')
      @amount_data = raw_transaction.fetch('amount')
      @native_amount_data = raw_transaction.fetch('native_amount')
      @amount_value = amount_data.fetch('amount')
      @amount_currency_sym = amount_data.fetch('currency')
      @native_value = native_amount_data.fetch('amount')
      @native_currency_sym = native_amount_data.fetch('amount')
    end

    attr_reader :raw_transaction,
                :type,
                :amount_data,
                :native_amount_data,
                :amount_value,
                :amount_currency_sym,
                :native_value,
                :native_currency_sym
  end
end
