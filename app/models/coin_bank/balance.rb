# frozen_string_literal: true

module CoinBank
  class Balance < ApplicationRecord
    belongs_to :user, class_name: "CoinBank::User", inverse_of: :balances
    belongs_to :currency, class_name: "CoinBank::Currency", inverse_of: :balances

    validates :amount, numericality: { greater_than_or_equal_to: 0 }
  end
end
