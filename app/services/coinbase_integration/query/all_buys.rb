# frozen_string_literal: true

module CoinbaseIntegration
  module Query
    class AllBuys
      include Results::Methods

      def initialize(output)
        @output = output
        @account_importer = Query::Accounts.new(output)
        @stored_buys = {}
      end

      def retrieve
        output.puts 'Iterating through account buys...'
        account_importer.retrieve.bind do |accounts|
          account_objects = accounts.values
          output.puts "...found #{account_objects.size} accounts..."
          store_buys_from(account_objects)
        end.bind do
          if stored_buys.empty?
            fail!('No buys to import.')
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

      delegate :values, to: :stored_buys

      private

      attr_reader :output, :account_importer, :stored_buys

      def store_buys_from(account_objects)
        account_objects.each do |account|
          query_buys(account['id']).or do |failure_message|
            output.puts "DEBUG: [#{account['name']}]: #{failure_message}"
            fail!(failure_message)
          end.fmap do |buys|
            @stored_buys = @stored_buys.merge(buys.to_h)
          end
        end
        succeed!(nil)
      end

      def query_buys(account_id)
        AccountBuys.new(output, account_id).retrieve
      end
    end
  end
end
