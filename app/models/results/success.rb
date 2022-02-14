# frozen_string_literal: true

module Results
  class Success < Base
    def status
      SUCCESS_STATUS
    end

    def value!
      object
    end

    def bind
      yield object

      self
    end

    def fmap
      yield object
    end

    def or
      object
    end
  end
end
