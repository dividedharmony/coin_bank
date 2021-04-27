# frozen_string_literal: true

module CoinBank
  class Balance < ApplicationRecord
    belongs_to :user, class_name: "CoinBank::User", inverse_of: :balances
    belongs_to :currency, class_name: "CoinBank::Currency", inverse_of: :balances

    # Users can go into negative amounts of a fiat currency
    # essentially going into debt. However, they cannot have
    # a negative balance of a cryptocurrency
    validates :amount, numericality: { greater_than_or_equal_to: 0 }, if: :crypto_balance?

    scope :latest_per_currency, -> { select('DISTINCT ON(currency_id) *').order(:currency_id, created_at: :desc) }

    private

    def crypto_balance?
      currency&.crypto?
    end
  end
end
