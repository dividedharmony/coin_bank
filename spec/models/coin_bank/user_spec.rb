# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:balances).class_name("CoinBank::Balance") }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end
end
