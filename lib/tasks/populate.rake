# frozen_string_literal: true

namespace :populate do
  desc 'Populate all transactions from the Coinbase api'
  task transactions: :environment do
    user = CoinBank::User.find_by!(email: 'dharmon@example.com')
    CoinbaseIntegration::Import::PersistTransactions.new(user: user).call
  end

  desc 'Populate all currencies from the Coinbase api'
  task currencies: :environment do
    CoinbaseIntegration::Query::Accounts.new(STDOUT).retrieve.or do |failure_message|
      raise StandardError, failure_message
    end.fmap do |accounts|
      accounts.values.each do |raw_account|
        raw_currency = raw_account.fetch('currency')
        next if CoinBank::Currency.exists?(symbol: raw_currency.fetch('code'))
        CoinBank::Currency.create!(
          symbol: raw_currency.fetch('code'),
          name: raw_currency.fetch('name'),
          slug: raw_currency.fetch('slug'),
          cmc_id: raw_currency.fetch('id'),
          logo_url: 'https://www.example.com/fake/logo.png'
        )
      end
    end
  end
end
