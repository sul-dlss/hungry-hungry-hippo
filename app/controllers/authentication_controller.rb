# frozen_string_literal: true

# Controller for login and logout.
class AuthenticationController < ApplicationController
  allow_unauthenticated_access only: %i[login test_login]
  skip_verify_authorized only: %i[login logout test_login]

  # See Authentication concern for the methods used below.

  def login
    start_new_session # Creates/updates user and set session cookie.
    redirect_to after_authentication_url
  end

  # This is used by specs to allow TestShibbolethHeaders middleware to set headers.
  # This endpoint is only available in the test environment.
  def test_login # rubocop:disable Metrics/AbcSize
    user = User.find(params[:id])
    cookies[:test_shibboleth_remote_user] = user.email_address
    cookies[:test_shibboleth_full_name] = user.name
    cookies[:test_shibboleth_first_name] = user.first_name
    cookies[:test_shibboleth_groups] = params[:groups] if params[:groups].present?

    head :ok
  end

  def logout
    terminate_session

    redirect_to SHIBBOLETH_LOGOUT_PATH
  end
end
