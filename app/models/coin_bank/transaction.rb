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
    validate :balance_integrity

    attr_accessor :from_currency_id, :to_currency_id

    def from_currency
      from_before_balance.currency
    end

    def to_currency
      to_before_balance.currency
    end

    private

    def balance_integrity
      return if [
        from_before_balance,
        from_after_balance,
        to_before_balance,
        to_after_balance
      ].any?(&:nil?)
      if from_before_balance.currency != from_after_balance.currency
        errors.add(:from_after_balance, "does not match the from_before_balance currency")
      end
      if to_before_balance.currency != to_after_balance.currency
        errors.add(:to_after_balance, "does not match the to_before_balance currency")
      end
    end
  end
end
