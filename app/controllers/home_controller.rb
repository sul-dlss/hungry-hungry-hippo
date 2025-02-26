# frozen_string_literal: true

# Controller for the home page
class HomeController < ApplicationController
  skip_verify_authorized only: :show

  def show
    redirect_to dashboard_path if allowed_to?(:show?, :dashboard)

    @hero_image = "home#{rand(1..18)}.webp"
  end
end
