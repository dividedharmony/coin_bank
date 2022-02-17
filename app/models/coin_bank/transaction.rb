# frozen_string_literal: true

module CoinBank
  class Transaction < ApplicationRecord
    belongs_to :user, class_name: "CoinBank::User", inverse_of: :transactions
    belongs_to :from_currency, class_name: "CoinBank::Currency", inverse_of: :from_transactions
    belongs_to :to_currency, class_name: "CoinBank::Currency", inverse_of: :to_transactions
    has_many :fees, class_name: "CoinBank::Fee", inverse_of: :cb_transaction, dependent: :destroy

    accepts_nested_attributes_for :fees, reject_if: :empty_fee?

    validates :transacted_at, presence: true
    validates :from_amount,
              :to_amount,
              :exchange_rate,
              :native_amount,
              numericality: true

    private

    def empty_fee?(fee_attr)
      fee_attr['amount'].blank? || (fee_attr['amount'].to_d <= 0)
    end
  end
end
