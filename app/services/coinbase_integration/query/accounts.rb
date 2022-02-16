# frozen_string_literal: true

module CoinbaseIntegration
  module Query
    class Accounts
      include Results::Methods
  
      def initialize(output)
        @output = output
        @client = Client.new
        @stored_accounts = {}
      end

      def retrieve
        next_starting_after = nil
        loop do
          output.puts "...Querying coinbase accounts..."
          client.accounts(starting_after_uuid: next_starting_after).or do |failure_message|
            raise StandardError, failure_message
          end.fmap do |api_resource|
            api_resource.each do |raw_account|
              output.puts "......found account #{raw_account['name']}"
              store_account(raw_account)
            end
            next_starting_after = api_resource.pagination['next_starting_after']
          end
          break if next_starting_after.nil?
        end
        if stored_accounts.empty?
          fail!('No accounts retrieved.')
        else
          succeed!(self)
        end
      end
  
      def [](account_id)
        get_account(account_id).or { fetch_and_store(account_id) }
      end

      delegate :values, to: :stored_accounts
  
      private
  
      attr_reader :output, :client, :stored_accounts

      def get_account(account_id)
        account_hash = stored_accounts[account_id]
        account_hash.nil? ?
          fail!("No account with id '#{account_id}'") :
          succeed!(account_hash)
      end

      def fetch_and_store(account_id)
        client.account(account_id).bind do |api_resource|
          store_account(api_resource.data)
        end
      end

      def store_account(raw_account)
        stored_accounts[raw_account['id']] = raw_account.with_indifferent_access
      end
    end
  end
end
