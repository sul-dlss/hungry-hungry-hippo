# frozen_string_literal: true

module Admin
  class DashboardPolicy < ApplicationPolicy
    def show?
      false # Admins are allowed by precheck
    end
  end
end
