# frozen_string_literal: true

# Controller for login and logout.
class AuthenticationController < ApplicationController
  allow_unauthenticated_access only: %i[login]
  skip_verify_authorized only: %i[login logout]

  # See Authentication concern for the methods used below.

  def login
    start_new_session # Creates/updates user and set session cookie.
    redirect_to after_authentication_url
  end

  def logout
    terminate_session

    redirect_to SHIBBOLETH_LOGOUT_PATH
  end
end
