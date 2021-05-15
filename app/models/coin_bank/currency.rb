# frozen_string_literal: true

module CoinBank
  class Currency < ApplicationRecord
    has_many :balances, class_name: "CoinBank::Balance", inverse_of: :currency
    has_many :from_transactions, class_name: "CoinBank::Transaction", inverse_of: :from_currency
    has_many :to_transactions, class_name: "CoinBank::Transaction", inverse_of: :to_currency
    has_many :fees, class_name: "CoinBank::Fee", inverse_of: :currency, dependent: :destroy

    validates :name,
              :symbol,
              :cmc_id,
              :slug,
              presence: true,
              uniqueness: { case_sensitive: false }

    scope :fiat, -> { where(fiat: true) }
    scope :crypto, -> { where(fiat: false) }

    def crypto?
      !fiat?
    end
  end
end
