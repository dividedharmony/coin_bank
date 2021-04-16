# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module CoinBank
  class CreateCurrency
    class << self
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      def call(params)
        given_symbol = params.dig(:coin_bank_currency, :symbol)
        yield validate_symbol(given_symbol)
        currency_json = yield CmcClient.new.info(symbol: given_symbol)
        new_currency = build_currency(currency_json)
        if new_currency.save
          Success(new_currency)
        else
          Failure(new_currency.errors.full_messages.join("\n"))
        end
      end
  
      private

      def validate_symbol(given_symbol)
        if given_symbol.present?
          Success(given_symbol)
        else
          Failure("No cryptocurrency symbol given. Please give a symbol for an existent cryptocurrency.")
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
