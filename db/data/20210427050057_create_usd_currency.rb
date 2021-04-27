# frozen_string_literal: true

class CreateUsdCurrency < ActiveRecord::Migration[6.1]
  def up
    CoinBank::Currency.create!(
      name: "US Dollar",
      symbol: "USD",
      slug: "usd",
      cmc_id: "NULL",
      fiat: true
    )
  end

  def down
    CoinBank::Currency.find_by(slug: "usd")&.destroy!
  end
end
