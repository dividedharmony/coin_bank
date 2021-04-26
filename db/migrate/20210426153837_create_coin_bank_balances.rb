# frozen_string_literal: true

class CreateCoinBankBalances < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_bank_balances do |t|
      t.references :user, null: false, foreign_key: { to_table: :coin_bank_users }
      t.references :currency, null: false, foreign_key: { to_table: :coin_bank_currencies }
      t.decimal :amount, null: false, default: 0, precision: 20, scale: 10

      t.timestamps
    end
  end
end
