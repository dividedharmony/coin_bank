# frozen_string_literal: true

module CoinBank
  class Currency < ApplicationRecord
    validates :name, :symbol, :slug, presence: true
  end
end
