# frozen_string_literal: true

class CoinBank::User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :balances, class_name: "CoinBank::Balance", inverse_of: :user
  has_many :current_balances,
           -> { latest_per_currency },
           class_name: "CoinBank::Balance",
           inverse_of: :user
end
