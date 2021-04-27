# frozen_string_literal: true

class AddFiatToCoinBankCurrency < ActiveRecord::Migration[6.1]
  def change
    add_column :coin_bank_currencies, :fiat, :boolean, null: false, default: false
  end
end
