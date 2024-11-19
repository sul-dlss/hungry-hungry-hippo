# frozen_string_literal: true

# Controller for the user dashboard
class DashboardController < ApplicationController
  skip_verify_authorized only: :show

  def show; end
end
