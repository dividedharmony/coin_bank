# frozen_string_literal: true

module CoinBank
  class CurrenciesController < ApplicationController
    def new
      @currency = CoinBank::Currency.new
    end

    def show
      @currency = CoinBank::Currency.find_by!(slug: params[:id])
    end

    def create
      result = CoinBank::CreateCurrency.(params)
      if result.success?
        currency = result.value!
        flash[:success] = "Successfully saved the #{currency.name} cryptocurrency!"
        redirect_to coin_bank_currency_path(currency.slug)
      else
        flash[:error] = result.failure
        redirect_to action: :new
      end
    end
  end
end
