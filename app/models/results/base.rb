# frozen_string_literal: true

module Results
  class Base
    def initialize(object:, message:)
      @object = object
      @message = message
    end

    attr_reader :object, :message

    def status
      raise NotImplementedError, "#{self.class.name} has not implemented a #status method"
    end

    def success?
      status == SUCCESS_STATUS
    end

    def failure?
      status == FAILURE_STATUS
    end

    def value!
      raise NotImplementedError, "#{self.class.name} has not implemented a #value! method"
    end

    def bind
      raise NotImplementedError, "#{self.class.name} has not implemented a #bind method"
    end

    def fmap
      raise NotImplementedError, "#{self.class.name} has not implemented a #fmap method"
    end

    def or
      raise NotImplementedError, "#{self.class.name} has not implemented a #or method"
    end

    def or_map
      raise NotImplementedError, "#{self.class.name} has not implemented a #or_map method"
    end
  end
end
