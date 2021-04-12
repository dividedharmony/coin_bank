# frozen_string_literal: true

class CreateCoinBankCurrencies < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_bank_currencies do |t|
      t.string :name, null: false
      t.string :symbol, null: false
      t.string :slug, null: false
      t.string :cmc_id, null: false
      t.string :logo_url, null: false, default: ""

      t.timestamps
    end
  end
end
