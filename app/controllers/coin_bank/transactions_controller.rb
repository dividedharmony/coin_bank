# frozen_string_literal: true

module CoinBank
  class TransactionsController < ApplicationController
    before_action :authenticate_user

    def new
      @transaction = CoinBank::Transaction.new
    end

    def create
      result = CoinBank::CreateTransaction.(
        current_user: current_user,
        params: params
      )
      if result.success?
        flash[:success] = "Successfully recorded transaction!"
        redirect_to action: :index
      else
        flash[:error] = result.failure
        redirect_to action: :new
      end
    end

    def index
      @transactions = CoinBank::Transaction.
        where(user: current_user).
        order(transacted_at: :desc)
    end

    private

    def authenticate_user
      return if current_user
      flash[:error] = "Please login."
      redirect_to root_path
    end
  end
end
