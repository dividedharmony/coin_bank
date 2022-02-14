# frozen_string_literal: true

module Results
  module Methods
    def succeed!(object)
      Results::Success.new(object: object, message: nil)
    end

    def fail!(message)
      Results::Failure.new(object: nil, message: message)
    end
  end
end
