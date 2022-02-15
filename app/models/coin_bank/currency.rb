# frozen_string_literal: true

module CoinBank
  class Currency < ApplicationRecord
    has_many :balances, class_name: "CoinBank::Balance", inverse_of: :currency
    has_many :from_transactions, class_name: "CoinBank::Transaction", inverse_of: :from_currency
    has_many :to_transactions, class_name: "CoinBank::Transaction", inverse_of: :to_currency

    validates :name,
              :symbol,
              :cmc_id,
              :slug,
              presence: true,
              uniqueness: { case_sensitive: false }

    def crypto?
      !fiat?
    end
  end
end
