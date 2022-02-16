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
        output.puts 'Beginning import...'
        retrieve_resources_from_api
        output.puts 'Finished retrieving from api...'
        return fail!('No transactions to import') if stored_transactions.empty?
        
        succeed!(self)
      end

      delegate :values, to: :stored_transactions

      private

      attr_reader :output, :account_importer, :stored_transactions

      def retrieve_resources_from_api
        account_importer.retrieve.bind do |accounts|
          accounts.values.each do |account|
            query_transactions(account[:id]).or do |failure_message|
              warning = "WARNING: [#{account[:name]}]: #{failure_message}"
              output.puts warning
              fail!(warning)
            end.fmap do |transactions|
              stored_transactions = stored_transactions.merge(transactions.to_h)
            end
          end
        end
      end

      def query_transactions(account_id)
        AccountTransactions.new(output, account_id).retrieve
      end
    end
  end
end
