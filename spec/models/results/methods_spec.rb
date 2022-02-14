# frozen_string_literal: true

require "rails_helper"

RSpec.describe Results::Methods do
  let(:mixed_class) do
    Class.new do
      include Results::Methods
    end
  end
  let(:mixed_instance) { mixed_class.new }

  describe '.succeed!' do
    subject { mixed_instance.succeed!('object value') }

    it 'returns a Success result' do
      expect(subject).to be_success
      expect(subject.object).to eq('object value')
      expect(subject.message).to be_nil
    end
  end

  describe '.fail!' do
    subject { mixed_instance.fail!('failure message') }
    
    it 'returns a Failure result' do
      expect(subject).to be_failure
      expect(subject.object).to be_nil
      expect(subject.message).to eq('failure message')
    end
  end
end
