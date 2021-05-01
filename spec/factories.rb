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
    association :from_before_balance, factory: :balance
    association :from_after_balance, factory: :balance
    association :to_before_balance, factory: :balance
    association :to_after_balance, factory: :balance
  end
end
