# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinBank::Fee do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("CoinBank::User").required }
    it { is_expected.to belong_to(:cb_transaction).class_name("CoinBank::Transaction").required }
    it { is_expected.to belong_to(:currency).class_name("CoinBank::Currency").required }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:amount).greater_than(0) }
  end
end
