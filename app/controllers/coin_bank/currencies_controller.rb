# frozen_string_literal: true

module CoinBank
  class CurrenciesController < ApplicationController
    def new
      @currency = CoinBank::Currency.new
    end

    def show
      @currency = CoinBank::Currency.find_by!(slug: params[:id])
    end
  end
end
