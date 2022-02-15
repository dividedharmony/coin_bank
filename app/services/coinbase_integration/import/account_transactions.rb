# frozen_string_literal: true

module CoinbaseIntegration
  module Import
    class AccountTransactions
      include Results::Methods
  
      def initialize(output, account_id)
        @output = output
        @client = Client.new
        @account_id = account_id
        @stored_transactions = {}
      end

      def retrieve
        next_starting_after = nil
        loop do
          output.puts "...Querying transactions for #{account_id}"
          query_transactions(next_starting_after).or do |failure_message|
            raise StandardError, failure_message
          end.fmap do |api_resource|
            api_resource.each do |raw_transaction|
              output.puts "......found a transaction for #{raw_transaction.dig('amount', 'amount')}"
              store_transaction(raw_transaction)
            end
            next_starting_after = api_resource.pagination['next_starting_after']
          end
          break if next_starting_after.nil?
        end
        if stored_transactions.empty?
          fail!('No transactions retrieved.')
        else
          succeed!(self)
        end
      end

      alias_method :to_h, :stored_transactions
  
      private
  
      attr_reader :output, :client, :account_id, :stored_transactions

      def query_transactions(next_starting_after)
        client.transactions(account_id, starting_after_uuid: next_starting_after)
      end

      def store_transaction(raw_transaction)
        stored_transactions[raw_transaction['id']] = raw_transaction.with_indifferent_access
      end
    end
  end
end
