# frozen_string_literal: true

class AddNativeAmountToCoinBankTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :coin_bank_transactions,
               :native_amount,
               :decimal,
               precision: 20,
               scale: 10,
               default: "0.0",
               null: false
  end
end
