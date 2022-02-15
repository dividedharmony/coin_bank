class CreateCoinBankTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :coin_bank_transactions do |t|
      t.references :user,
                   null: false,
                   foreign_key: { to_table: :coin_bank_users },
                   index: true
      # ORIGIN
      t.references :from_currency,
                   null: false,
                   foreign_key: { to_table: :coin_bank_currencies },
                   index: true
      t.decimal :from_amount, precision: 20, scale: 10, default: "0.0", null: false

      # DESTINATION
      t.references :to_currency,
                   null: false,
                   foreign_key: { to_table: :coin_bank_currencies },
                   index: true
      t.decimal :to_amount, precision: 20, scale: 10, default: "0.0", null: false

      t.decimal :exchange_rate, precision: 20, scale: 10, default: "0.0", null: false
      t.datetime :transacted_at, null: false
      t.string :coinbase_uuid, null: true, index: true

      t.timestamps
    end
  end
end
