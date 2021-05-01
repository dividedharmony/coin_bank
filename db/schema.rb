# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_27_131605) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coin_bank_balances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "amount", precision: 20, scale: 10, default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["currency_id"], name: "index_coin_bank_balances_on_currency_id"
    t.index ["user_id"], name: "index_coin_bank_balances_on_user_id"
  end

  create_table "coin_bank_currencies", force: :cascade do |t|
    t.string "name", null: false
    t.string "symbol", null: false
    t.string "slug", null: false
    t.string "cmc_id", null: false
    t.string "logo_url", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "fiat", default: false, null: false
  end

  create_table "coin_bank_transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "from_before_balance_id", null: false
    t.bigint "to_before_balance_id", null: false
    t.bigint "from_after_balance_id", null: false
    t.bigint "to_after_balance_id", null: false
    t.decimal "from_amount", precision: 20, scale: 10, default: "0.0", null: false
    t.decimal "to_amount", precision: 20, scale: 10, default: "0.0", null: false
    t.decimal "fee_amount", precision: 20, scale: 10, default: "0.0", null: false
    t.decimal "exchange_rate", precision: 20, scale: 10, default: "0.0", null: false
    t.datetime "transacted_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["from_after_balance_id"], name: "index_coin_bank_transactions_on_from_after_balance_id"
    t.index ["from_before_balance_id"], name: "index_coin_bank_transactions_on_from_before_balance_id"
    t.index ["to_after_balance_id"], name: "index_coin_bank_transactions_on_to_after_balance_id"
    t.index ["to_before_balance_id"], name: "index_coin_bank_transactions_on_to_before_balance_id"
    t.index ["user_id"], name: "index_coin_bank_transactions_on_user_id"
  end

  create_table "coin_bank_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_coin_bank_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_coin_bank_users_on_reset_password_token", unique: true
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  add_foreign_key "coin_bank_balances", "coin_bank_currencies", column: "currency_id"
  add_foreign_key "coin_bank_balances", "coin_bank_users", column: "user_id"
  add_foreign_key "coin_bank_transactions", "coin_bank_balances", column: "from_after_balance_id"
  add_foreign_key "coin_bank_transactions", "coin_bank_balances", column: "from_before_balance_id"
  add_foreign_key "coin_bank_transactions", "coin_bank_balances", column: "to_after_balance_id"
  add_foreign_key "coin_bank_transactions", "coin_bank_balances", column: "to_before_balance_id"
  add_foreign_key "coin_bank_transactions", "coin_bank_users", column: "user_id"
end
