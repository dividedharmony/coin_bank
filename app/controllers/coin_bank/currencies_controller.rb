# frozen_string_literal: true

module CoinBank
  class CurrenciesController < ApplicationController
    def new
      @currency = CoinBank::Currency.new
    end
  end
end
