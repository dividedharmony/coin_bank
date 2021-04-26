# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoinBank::Balance, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("CoinBank::User").required }
    it { is_expected.to belong_to(:currency).class_name("CoinBank::Currency").required }
  end

  describe "validations" do
    subject { build(:balance) }

    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end
end
