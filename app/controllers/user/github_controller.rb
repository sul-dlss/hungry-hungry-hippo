# frozen_string_literal: true

class User
  # Controller for managing a user's GitHub integration status and settings
  class GithubController < ApplicationController
    skip_verify_authorized # This is always going to be for the current user so there's no need to authorize.

    def show; end

    def create # rubocop:disable Metrics/AbcSize
      # Redirect from GitHub after the user authorizes the application.
      # Note that this is a GET, not a POST.
      auth = request.env['omniauth.auth']
      current_user.update!(github_access_token: auth.credentials.token,
                           github_uid: auth.uid,
                           github_nickname: auth.info.nickname,
                           github_connected_at: Time.zone.now,
                           github_updated_at: Time.zone.now)

      flash[:success] = I18n.t('github.connected_account')
      redirect_to user_github_path
    end
  end
end
