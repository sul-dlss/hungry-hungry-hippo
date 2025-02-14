# frozen_string_literal: true

module Admin
  # Controller for the admin dashboard
  class DashboardController < Admin::ApplicationController
    def show
      authorize!
    end
  end
end
