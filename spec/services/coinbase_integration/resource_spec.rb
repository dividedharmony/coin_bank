# frozen_string_literal: true

require "rails_helper"

RSpec.describe CoinbaseIntegration::Resource do
  let(:resource) do
    described_class.new({
      'data' => [
        {
          'id' => 'thing1'
        },
        {
          'id' => 'thing2'
        }
      ],
      'pagination' => {
        'starting_after' => 'abc123'
      },
      'errors' => [
        {
          'message' => 'Service is degraded.'
        },
        {
          'message' => 'Universe is uncertain.'
        }
      ]
    })
  end

  describe '#data' do
    subject { resource.data }

    specify do
      is_expected.to eq([
        {
          'id' => 'thing1'
        },
        {
          'id' => 'thing2'
        }
      ])
    end
  end

  describe '#pagination' do
    subject { resource.pagination }

    specify do
      is_expected.to eq({
        'starting_after' => 'abc123'
      })
    end
  end

  describe '#error_message' do
    subject { resource.error_message }

    specify do
      is_expected.to eq("Service is degraded.\nUniverse is uncertain.")
    end
  end
end
