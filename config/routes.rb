# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"

  scope module: :coin_bank do
    resources :currencies, as: :coin_bank_currencies
  end
end
