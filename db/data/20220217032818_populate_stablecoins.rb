# frozen_string_literal: true

class PopulateStablecoins < ActiveRecord::Migration[6.1]
  DAI_SYMBOL = 'DAI'
  TETHER_SYMBOL = 'USDT'
  USD_COIN_SYMBOL = 'USDC'
  BINANCE_SYMBOL = 'BUSD'
  TRUE_USD_SYMBOL = 'TUSD'
  TERRA_USD_SYMBOL = 'UST'

  def up
    CoinBank::Currency.create!(
      name: 'Dai',
      slug: 'multi-collateral-dai',
      symbol: DAI_SYMBOL,
      logo_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/4943.png',
      cmc_id: 4943,
      stablecoin: true
    )
    CoinBank::Currency.create!(
      name: 'Tether',
      slug: 'tether',
      symbol: TETHER_SYMBOL,
      logo_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/825.png',
      cmc_id: 825,
      stablecoin: true
    )
    CoinBank::Currency.create!(
      name: 'USD Coin',
      slug: 'usd-coin',
      symbol: USD_COIN_SYMBOL,
      logo_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/3408.png',
      cmc_id: 3408,
      stablecoin: true
    )
    CoinBank::Currency.create!(
      name: 'Binance USD',
      slug: 'binance-usd',
      symbol: BINANCE_SYMBOL,
      logo_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/4687.png',
      cmc_id: 4687,
      stablecoin: true
    )
    CoinBank::Currency.create!(
      name: 'TrueUSD',
      slug: 'trueusd',
      symbol: TRUE_USD_SYMBOL,
      logo_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/2563.png',
      cmc_id: 2563,
      stablecoin: true
    )
    CoinBank::Currency.create!(
      name: 'TerraUSD',
      slug: 'terrausd',
      symbol: TERRA_USD_SYMBOL,
      logo_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/7129.png',
      cmc_id: 7129,
      stablecoin: true
    )
  end

  def down
    CoinBank::Currency.where(symbol: [
      DAI_SYMBOL,
      TETHER_SYMBOL,
      USD_COIN_SYMBOL,
      BINANCE_SYMBOL,
      TRUE_USD_SYMBOL,
      TERRA_USD_SYMBOL,
    ]).each(&:destroy!)
  end
end
