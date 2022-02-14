# frozen_string_literal: true

module CoinBank
  class CreateCurrency
    class << self
      include Results::Methods

      def call(params)
        given_symbol = params.dig(:coin_bank_currency, :symbol)
        validate_symbol(given_symbol).bind do |symbol|
          CmcClient.new.info(symbol: given_symbol)
        end.bind do |currency_json|
          new_currency = build_currency(currency_json)
          if new_currency.save
            succeed!(new_currency)
          else
            fail!(new_currency.errors.full_messages.join("\n"))
          end
        end
      end
  
      private

      def validate_symbol(given_symbol)
        if given_symbol.present?
          succeed!(given_symbol)
        else
          fail!("No cryptocurrency symbol given. Please give a symbol for an existent cryptocurrency.")
        end
      end
  
      def build_currency(currency_json)
        CoinBank::Currency.new(
          name: currency_json['name'],
          slug: currency_json['slug'],
          symbol: currency_json['symbol'],
          logo_url: currency_json['logo'],
          cmc_id: currency_json['id']
        )
      end
    end
  end
end
