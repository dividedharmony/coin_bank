# frozen_string_literal: true

module CoinbaseIntegration
  module Query
    class AllTransactions
      include Results::Methods

      def initialize(output)
        @output = output
        @account_importer = Query::Accounts.new(output)
        @stored_transactions = {}
      end

      def retrieve
        output.puts 'Iterating through account transactions...'
        account_importer.retrieve.bind do |accounts|
          store_transactions_from(accounts.values)
        end.bind do
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

      def store_transactions_from(account_objects)
        account_objects.each do |account|
          query_transactions(account['id']).or do |failure_message|
            output.puts "DEBUG: [#{account['name']}]: #{failure_message}"
            fail!(failure_message)
          end.fmap do |transactions|
            @stored_transactions = @stored_transactions.merge(transactions.to_h)
          end
        end
        succeed!(nil)
      end

      def query_transactions(account_id)
        AccountTransactions.new(output, account_id).retrieve
      end
    end
  end
end
