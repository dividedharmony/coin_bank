# frozen_string_literal: true

require "rails_helper"

RSpec.describe Results::Base do
  describe 'as an abstract class' do
    let(:instance) { described_class.new(object: nil, message: nil) }

    describe '#status' do
      subject { instance.status }

      it 'is not implemented' do
        expect { subject }.to raise_error(NotImplementedError, "Results::Base has not implemented a #status method")
      end
    end

    describe '#value!' do
      subject { instance.value! }
      
      it 'is not implemented' do
        expect { subject }.to raise_error(NotImplementedError, "Results::Base has not implemented a #value! method")
      end
    end

    describe '#bind' do
      subject { instance.bind }
      
      it 'is not implemented' do
        expect { subject }.to raise_error(NotImplementedError, "Results::Base has not implemented a #bind method")
      end
    end

    describe '#or' do
      subject { instance.or }
      
      it 'is not implemented' do
        expect { subject }.to raise_error(NotImplementedError, "Results::Base has not implemented a #or method")
      end
    end
  end

  describe 'as a parent class' do
    let(:subclass) do
      Class.new(described_class) do
        def initialize(status)
          @status = status
          super(object: nil, message: nil)
        end

        attr_reader :status
      end
    end

    describe '#success?' do
      subject { subclass_instance.success? }

      context 'if status is :success' do
        let(:subclass_instance) { subclass.new(:success) }

        it { is_expected.to be true }
      end

      context 'if status is not success' do
        let(:subclass_instance) { subclass.new(:failure) }

        it { is_expected.to be false }
      end
    end

    describe '#failure?' do
      subject { subclass_instance.failure? }

      context 'if status is :failure' do
        let(:subclass_instance) { subclass.new(:failure) }

        it { is_expected.to be true }
      end

      context 'if status is not failure' do
        let(:subclass_instance) { subclass.new(:success) }

        it { is_expected.to be false }
      end
    end
  end
end
