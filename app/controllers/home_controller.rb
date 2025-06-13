# frozen_string_literal: true

# Controller for the home page
class HomeController < ApplicationController
  allow_unauthenticated_access only: :show
  skip_verify_authorized only: :show

  def show
    @hero_image = "home#{rand(1..18)}.webp"
  end
end
