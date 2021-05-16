# frozen_string_literal: true

class CreateCoinbaseRewardsCurrency < ActiveRecord::Migration[6.1]
  def up
    CoinBank::Currency.create!(
      name: "Coinbase Rewards",
      symbol: "COINBASE REWARDS",
      slug: "coinbaserewards",
      cmc_id: "NULL2",
      fiat: true
    )
  end

  def down
    CoinBank::Currency.find_by(slug: "coinbaserewards")&.destroy!
  end
end
