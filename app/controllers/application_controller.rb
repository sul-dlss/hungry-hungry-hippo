# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # By default, requires authentication for all controllers.
  # To allow unauthenticated access, use the allow_unauthenticated_access method.
  # Also provides the current_user method.
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
