# frozen_string_literal: true

module Results
  class Failure < Base
    class FailedValueError < StandardError
      def initialize(msg='Cannot return a #value! for a Failure result')
        super
      end
    end
    class InvalidOrReturnValue < StandardError
      def initialize(msg='Return value for Failure#or block must be a Results::Base instance')
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
      outcome = yield
      raise InvalidOrReturnValue unless outcome.is_a?(Results::Base)

      outcome
    end

    def or_map
      yield
    end
  end
end
