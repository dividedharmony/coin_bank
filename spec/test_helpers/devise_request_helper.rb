# frozen_string_literal: true

require 'warden'

module TestHelpers
  # Devise sign in/sign out helpers do not work with
  # request specs. This helper provides those methods
  # for request specs.
  module DeviseRequestHelper
    include Warden::Test::Helpers
  
    def sign_in_as!(resource_or_scope, resource = nil)
      resource ||= resource_or_scope
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      login_as(resource, scope: scope)
    end
  
    def sign_out!(resource_or_scope)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      logout(scope)
    end
  end
end
