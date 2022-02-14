# frozen_string_literal: true

module Results
  class Success < Base
    class InvalidBindReturnValue < StandardError
      def initialize(msg='Return value for Success#bind block must be a Results::Base instance')
        super
      end
    end

    def status
      SUCCESS_STATUS
    end

    def value!
      object
    end

    def bind
      outcome = yield object
      raise InvalidBindReturnValue unless outcome.is_a?(Results::Base)

      outcome
    end

    def fmap
      yield object
    end

    def or
      self
    end

    def or_map
      object
    end
  end
end
