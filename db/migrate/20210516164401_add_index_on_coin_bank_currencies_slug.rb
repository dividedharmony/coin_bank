# frozen_string_literal: true

class AddIndexOnCoinBankCurrenciesSlug < ActiveRecord::Migration[6.1]
  def change
    add_index :coin_bank_currencies, :slug
    add_index :coin_bank_currencies, :symbol
  end
end
