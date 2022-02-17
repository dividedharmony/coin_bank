# frozen_string_literal: true

class AddStablecoinToCoinBankCurrencies < ActiveRecord::Migration[6.1]
  def change
    add_column :coin_bank_currencies, :stablecoin, :boolean, null: false, default: false
  end
end
