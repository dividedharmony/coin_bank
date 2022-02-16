# frozen_string_literal: true

module CoinbaseIntegration
  module Query
    class AccountBuys
      class QueryFailed < StandardError; end

      include Results::Methods
  
      def initialize(output, account_id)
        @output = output
        @client = Client.new
        @account_id = account_id
        @stored_buys = {}
      end

      def retrieve
        next_starting_after = nil
        loop do
          output.puts "...Querying buys for #{account_id}"
          query_buys(next_starting_after).or do |failure_message|
            raise QueryFailed, failure_message
          end.fmap do |api_resource|
            api_resource.each do |raw_buy|
              output.puts "......found a buy for #{raw_buy.dig('amount', 'amount')}"
              store_buy(raw_buy)
            end
            next_starting_after = api_resource.pagination['next_starting_after']
          end
          break if next_starting_after.nil?
        end
        if stored_buys.empty?
          fail!('No buys retrieved.')
        else
          succeed!(self)
        end
      end

      attr_reader :stored_buys
      alias_method :to_h, :stored_buys
  
      private
  
      attr_reader :output, :client, :account_id

      def query_buys(next_starting_after)
        client.buys(account_id, starting_after_uuid: next_starting_after)
      end

      def store_buy(raw_buy)
        stored_buys[raw_buy['id']] = raw_buy
      end
    end
  end
end
