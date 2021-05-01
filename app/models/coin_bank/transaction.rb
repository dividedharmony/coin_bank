# frozen_string_literal: true

module CoinBank
  class Transaction < ApplicationRecord
    belongs_to :user, class_name: "CoinBank::User", inverse_of: :transactions
    belongs_to :from_before_balance, class_name: "CoinBank::Balance"
    belongs_to :from_after_balance, class_name: "CoinBank::Balance"
    belongs_to :to_before_balance, class_name: "CoinBank::Balance"
    belongs_to :to_after_balance, class_name: "CoinBank::Balance"

    validates :transacted_at, presence: true
    validates :from_amount,
              :to_amount,
              :fee_amount,
              :exchange_rate,
              numericality: { greater_than_or_equal_to: 0 }
  end
end
