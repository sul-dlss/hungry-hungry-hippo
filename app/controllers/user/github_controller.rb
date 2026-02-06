# frozen_string_literal: true

class User
  # Controller for managing a user's GitHub integration status and settings
  class GithubController < ApplicationController
    skip_verify_authorized # This is always going to be for the current user so there's no need to authorize.

    def show; end
  end
end
