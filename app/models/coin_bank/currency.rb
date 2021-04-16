# frozen_string_literal: true

module CoinBank
  class Currency < ApplicationRecord
    validates :name,
              :symbol,
              :cmc_id,
              :slug,
              presence: true,
              uniqueness: { case_sensitive: false }
  end
end
