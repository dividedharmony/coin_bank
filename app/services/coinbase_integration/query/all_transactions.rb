# frozen_string_literal: true

module CoinbaseIntegration
  module Query
    class AllTransactions
      class QueryFailed < StandardError; end

      include Results::Methods

      def initialize(output)
        @output = output
        @account_importer = Query::Accounts.new(output)
        @stored_transactions = {}
      end

      def retrieve
        output.puts 'Beginning import...'
        account_importer.retrieve.bind do |accounts|
          store_transactions_from(accounts)
        end.bind do
          stored_transactions.empty? ? fail!('No transactions to import') : succeed!(nil)
          if stored_transactions.empty?
            fail!('No transactions to import.')
          else
            output.puts 'Finished retrieving from api...'
            succeed!(self)
          end
        end.or do |failure_message|
          warning = "WARNING: #{failure_message}"
          output.puts warning
          fail!(failure_message)
        end
      end

      delegate :values, to: :stored_transactions

      private

      attr_reader :output, :account_importer, :stored_transactions

      def store_transactions_from(accounts)
        accounts.values.each do |account|
          query_transactions(account['id']).or do |failure_message|
            raise QueryFailed, "[#{account['name']}]: #{failure_message}"
          end.fmap do |transactions|
            @stored_transactions = @stored_transactions.merge(transactions.to_h)
          end
        end
        succeed!(nil)
      rescue QueryFailed => e
        fail!(e.message)
      end

      def query_transactions(account_id)
        AccountTransactions.new(output, account_id).retrieve
      end
    end
  end
end
