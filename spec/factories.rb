# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'CoinBank::User' do
    sequence :email do |n|
      "random_#{n}th_user@example.com"
    end
    password { "fake2468password" }
    password_confirmation { "fake2468password" }
  end

  factory :currency, class: CoinBank::Currency do
    sequence :name do |n|
      "Bitcoin ##{n}th Fork"
    end
    sequence :symbol do |n|
      "B#{n}F"
    end
    sequence :slug do |n|
      "bitcoin_##{n}_fork"
    end
    sequence :cmc_id do |n|
      "BFORK#{n}"
    end
    logo_url { "https://www.example.com/fake_logo.png" }
  end

  factory :balance, class: CoinBank::Balance do
    user
    currency
  end

  factory :transaction, class: CoinBank::Transaction do
    user
    transacted_at { Time.zone.now }

    after :build do |trans|
      if trans.from_before_balance.nil? || trans.from_after_balance.nil?
        from_currency = trans.from_before_balance&.currency ||
          trans.from_after_balance&.currency ||
          create(:currency)
        trans.from_before_balance ||= create(:balance, currency: from_currency)
        trans.from_after_balance ||= create(:balance, currency: from_currency)
      end
      if trans.to_before_balance.nil? || trans.to_after_balance.nil?
        to_currency = trans.to_before_balance&.currency ||
          trans.to_after_balance&.currency ||
          create(:currency)
        trans.to_before_balance ||= create(:balance, currency: to_currency)
        trans.to_after_balance ||= create(:balance, currency: to_currency)
      end
    end
  end
end
