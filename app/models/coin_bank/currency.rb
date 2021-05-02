# frozen_string_literal: true

module CoinBank
  class Currency < ApplicationRecord
    has_many :balances, class_name: "CoinBank::Balance", inverse_of: :currency

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
