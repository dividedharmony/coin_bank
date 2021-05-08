# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"

  devise_for :users, class_name: "CoinBank::User"

  scope module: :coin_bank do
    resources :currencies, as: :coin_bank_currencies
    resources :transactions, only: %i(new create index), as: :coin_bank_transactions
  end
end
