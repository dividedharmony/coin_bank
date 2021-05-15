# frozen_string_literal: true

class CreateCoinBankFees < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_bank_fees do |t|
      t.references :transaction, null: false, foreign_key: { to_table: :coin_bank_transactions }
      t.references :user, null: false, foreign_key: { to_table: :coin_bank_users }
      t.references :currency, null: false, foreign_key: { to_table: :coin_bank_currencies }

      t.decimal :amount, null: false, default: 0, precision: 20, scale: 10

      t.timestamps
    end
  end
end
