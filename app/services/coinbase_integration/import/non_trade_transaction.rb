# frozen_string_literal: true

module CoinbaseIntegration
  module Import
    class NonTradeTransaction
      def initialize(currencies)
        @currencies = currencies
      end

      def import!(user, raw_transaction)
        transaction_struct = TransactionStruct.new(raw_transaction)
        CoinBank::Transaction.create!(
          user: user,
          from_currency: currencies.fetch(transaction_struct.from_currency_symbol),
          from_amount: transaction_struct.from_amount,
          to_currency: currencies.fetch(transaction_struct.to_currency_symbol),
          to_amount: transaction_struct.to_amount,
          native_amount: transaction_struct.native_amount,
          exchange_rate: transaction_struct.exchange_rate,
          transacted_at: transaction_struct.transacted_at,
          coinbase_uuid: transaction_struct.coinbase_uuid
        )
      end

      private

      attr_reader :currencies
    end
  end
end
