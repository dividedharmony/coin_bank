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
    association :from_currency, factory: :currency
    association :to_currency, factory: :currency
    transacted_at { 3.days.ago }
    from_amount { 3.14 }
    to_amount { 6.28 }
    exchange_rate { 2 }
  end
end
