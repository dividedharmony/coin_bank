# frozen_string_literal: true

module CoinBank
  class Transaction < ApplicationRecord
    belongs_to :user, class_name: "CoinBank::User", inverse_of: :transactions
    belongs_to :from_currency, class_name: "CoinBank::Currency", inverse_of: :from_transactions
    belongs_to :to_currency, class_name: "CoinBank::Currency", inverse_of: :to_transactions

    validates :transacted_at, presence: true
    validates :from_amount,
              :to_amount,
              :exchange_rate,
              numericality: true
  end
end
