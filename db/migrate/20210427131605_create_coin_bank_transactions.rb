# frozen_string_literal: true

class CreateCoinBankTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_bank_transactions do |t|
      t.references :user, null: false, foreign_key: { to_table: :coin_bank_users }
      t.references :from_before_balance, null: false, foreign_key: { to_table: :coin_bank_balances }
      t.references :to_before_balance, null: false, foreign_key: { to_table: :coin_bank_balances }
      t.references :from_after_balance, null: false, foreign_key: { to_table: :coin_bank_balances }
      t.references :to_after_balance, null: false, foreign_key: { to_table: :coin_bank_balances }

      t.decimal :from_amount, null: false, default: 0, precision: 20, scale: 10
      t.decimal :to_amount, null: false, default: 0, precision: 20, scale: 10
      t.decimal :fee_amount, null: false, default: 0, precision: 20, scale: 10
      t.decimal :exchange_rate, null: false, default: 0, precision: 20, scale: 10

      t.datetime :transacted_at, null: false
      t.timestamps
    end
  end
end
