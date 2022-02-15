# frozen_string_literal: true

module CoinbaseIntegration
  module Import
    class AllTransactions
      def initialize(output: STDOUT)
        @output = output
        @client = Client.new
        @account_importer = Accounts.new(output)
        @temp_transactions = {}
      end

      def call
        output.puts 'Beginning import...'
        retrieve_resources_from_api
        output.puts 'Finished retrieving from api...'
        return fail!('No transactions to import') if temp_transactions.empty?

        # TODO save temp transactions
      end

      private

      attr_reader :output, :client, :account_importer, :temp_transactions

      def retrieve_resources_from_api
        account_importer.retrieve.bind do |accounts|
          accounts.values.each do |account|
            query_transactions(account[:id]).or do |failure_message|
              warning = "WARNING: [#{account[:name]}]: #{failure_message}"
              output.puts warning
              fail!(warning)
            end.fmap do |transactions|
              temp_transactions = temp_transactions.merge(transactions.to_h)
            end
          end
        end
      end

      def query_transactions(account_id)
        Transactions.new(output, account_id).retrieve
      end
    end
  end
end
