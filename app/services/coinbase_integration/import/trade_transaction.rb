# frozen_string_literal: true

module CoinbaseIntegration
  module Import
    class TradeTransaction
      class TradeNotFound < StandardError
        def initialize(trade_id)
          super("Could not find trade object with 'id' #{trade_id}")
        end
      end

      def initialize(currencies)
        @currencies = currencies
      end

      def import!(user, raw_trade)
        raw_input = raw_trade.fetch('input_amount')
        raw_output = raw_trade.fetch('output_amount')

        from_currency = currencies.fetch(raw_input.fetch('currency'))
        to_currency = currencies.fetch(raw_output.fetch('currency'))

        CoinBank::Transaction.create!(
          user: user,
          from_currency: from_currency,
          from_amount: raw_input.fetch('amount').to_d,
          to_currency: to_currency,
          to_amount: raw_output.fetch('amount').to_d,
          exchange_rate: raw_trade.fetch('exchange_rate').fetch('amount'),
          native_amount: native_amount(raw_trade),
          transacted_at: raw_trade.fetch('created_at').to_datetime,
          coinbase_uuid: raw_trade.fetch('id'),
          fees_attributes: [
            build_fee(user, raw_trade, currencies)
          ]
        )
      end

      private

      attr_reader :currencies

      def build_fee(user, raw_trade, currencies)
        raw_fee = raw_trade['fee']
        return {} if raw_fee.blank?

        {
          user: user,
          amount: raw_fee.fetch('amount'),
          currency: currencies.fetch(raw_fee.fetch('currency'))
        }
      end

      def native_amount(raw_trade)
        raw_trade.fetch('display_input_amount').fetch('amount')
      end
    end
  end
end
