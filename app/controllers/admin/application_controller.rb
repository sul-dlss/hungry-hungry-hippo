# frozen_string_literal: true

module Admin
  # Base controller for admin functions
  class ApplicationController < ::ApplicationController
    def self.policy_name
      'AdminPolicy'
    end

    def implicit_authorization_target
      self
    end
  end
end
