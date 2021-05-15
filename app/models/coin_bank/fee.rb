# frozen_string_literal: true

module CoinBank
  class Fee < ApplicationRecord
    belongs_to :cb_transaction,
               class_name: "CoinBank::Transaction",
               inverse_of: :fees,
               foreign_key: :transaction_id
    belongs_to :user, class_name: "CoinBank::User", inverse_of: :fees
    belongs_to :currency, class_name: "CoinBank::Currency", inverse_of: :fees
  end
end
