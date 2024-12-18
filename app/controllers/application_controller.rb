# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # By default, requires authentication for all controllers.
  # To allow unauthenticated access, use the allow_unauthenticated_access method.
  # Also provides the current_user method.
  include Authentication
  include Pundit::Authorization

  # Adds an after_action callback to verify that `authorize` has been called.
  # See https://github.com/varvet/pundit#conditional-verification for how to skip.
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :deny_access

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def deny_access
    flash[:warning] = helpers.t('errors.not_authorized')
    redirect_to main_app.root_path
  end
end
