# frozen_string_literal: true

# require coin_bank as our classes are
# namespaced inside of it
require 'coin_bank'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
