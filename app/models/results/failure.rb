# frozen_string_literal: true

module Results
  class Failure < Base
    class FailedValueError < StandardError
      def initialize(msg='Cannot return a #value! for a Failure result')
        super
      end
    end

    def status
      FAILURE_STATUS
    end

    def value!
      raise FailedValueError
    end

    def bind
      self
    end

    def fmap
      nil
    end

    def or
      yield
    end
  end
end
