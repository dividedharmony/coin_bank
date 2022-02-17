# frozen_string_literal: true

namespace :populate do
  desc 'Populate all transactions from the Coinbase api'
  task transactions: :environment do
    user = CoinBank::User.find_by!(email: 'dharmon@example.com')
    CoinbaseIntegration::Import::PersistTransactions.new(user: user).call
  end
end
