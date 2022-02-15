# frozen_string_literal: true

module CoinbaseIntegration
  module Query
    class Trades
      include Results::Methods
  
      def initialize(output)
        @output = output
        @client = Client.new
        @stored_trades = {}
      end

      def retrieve
        output.puts "...Querying coinbase trades..."
        client.trades.or do |failure_message|
          raise StandardError, failure_message
        end.fmap do |api_resource|
          api_resource.each do |raw_trade|
            output.puts "......found trade #{trade_display(raw_trade)}"
            store_trade(raw_trade)
          end
        end
        
        if stored_trades.empty?
          fail!('No trades retrieved.')
        else
          succeed!(self)
        end
      end

      alias_method :to_h, :stored_trades
      delegate :values, to: :stored_trades
  
      private
  
      attr_reader :output, :client, :stored_trades

      def store_trade(raw_trade)
        stored_trades[raw_trade['id']] = raw_trade.with_indifferent_access
      end

      def trade_display(raw_trade)
        input_currency = raw_trade.dig('input_amount', 'currency')
        output_currency = raw_trade.dig('output_amount', 'currency')
        "#{input_currency} ==> #{output_currency}"
      end
    end
  end
end
