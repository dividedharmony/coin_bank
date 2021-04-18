# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinBank::CurrenciesController, type: :request do
  describe "GET #new" do
    subject do
      get "/currencies/new"
      response
    end

    it "builds a new currency" do
      subject
      expect(assigns[:currency]).to be_instance_of(CoinBank::Currency)
      expect(assigns[:currency]).not_to be_persisted
    end
  end

  describe "GET #show" do
    subject do
      get "/currencies/etherium"
      response
    end

    context "if currency with slug does not exist" do
      it { is_expected.to have_http_status(:not_found) }
    end

    context "if currency with slug does exist" do
      let!(:currency) { create(:currency, slug: "etherium") }

      it "displays that currency" do
        subject
        expect(assigns[:currency]).to eq(currency)
      end
    end
  end

  describe "POST #create"
end
