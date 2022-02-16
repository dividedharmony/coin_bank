# frozen_string_literal: true

module CoinbaseIntegration
  module Import
    class PersistTransactions
      class TradeNotFound < StandardError
        def initialize(trade_id)
          super("Could not find trade object with 'id' #{trade_id}")
        end
      end

      include Results::Methods

      def initialize(output: STDOUT, user:)
        @output = output
        @user = user
        @currencies = CoinbaseIntegration::Currencies.new(
          CoinBank::Currency.find_by!(symbol: CoinBank::Currency::USD_SYMBOL),
          CoinBank::Currency.find_by!(symbol: CoinBank::Currency::REWARDS_SYMBOL)
        )
        @trades = {}
        @trade_importer = TradeTransaction.new(currencies)
        @non_trade_importer = NonTradeTransaction.new(currencies)
        @finished_transactions = Set.new
        @finished_trades = Set.new
      end

      def call
        query_trades

        all_transactions.bind do |raw_transactions|
          output.puts "IMPORTING #{raw_transactions.values.count} TRANSACTIONS!!"
          raw_transactions.values.each do |raw_transaction|
            if raw_transaction['type'] == 'trade'
              import_trade_transaction(raw_transaction)
            else
              import_non_trade_transaction(raw_transaction)
            end
          end
          output.puts 'FINISHED IMPORT!!'
        end
      end

      private

      attr_reader :output, :user, :reward_currency, :usd_currency, :currencies,
                  :trades, :finished_trades, :finished_transactions, :trade_importer, :non_trade_importer

      def query_trades
        Query::Trades.new(output).retrieve.or do |failure_message|
          raise StandardError, "WARNING: #{failure_message}"
        end.fmap do |trades_result|
          @trades = trades_result.to_h
        end
      end

      def all_transactions
        Query::AllTransactions.new(output).retrieve
      end

      def import_trade_transaction(raw_transaction)
        transaction_uuid = raw_transaction['id']
        trade_id = raw_transaction['trade'].fetch('id')
        return finished_trades.include?(trade_id) || finished_transactions.include?(transaction_uuid)
        raw_trade = raw_trades[trade_id]
        raise TradeNotFound, trade_id if raw_trade.nil?

        trade_importer.import!(user, raw_trade)
        output.puts ".........successfully persisted TRADE #{trade_id}"
        finished_trades << trade_id
        finished_transactions << transaction_uuid
      end

      def import_non_trade_transaction(raw_transaction)
        transaction_uuid = raw_transaction['id']
        return if finished_transactions.include?(transaction_uuid)

        NonTradeTransaction.impot!(user, raw_transaction)
        output.puts ".........successfully persisted NON-TRADE #{raw_transaction['type']} transaction"
        finished_transactions << transaction_uuid
      end
    end
  end
end
