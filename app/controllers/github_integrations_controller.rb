# frozen_string_literal: true

# Controller to handle GitHub authorization callbacks for linking user accounts.
class GithubIntegrationsController < ApplicationController
  allow_unauthenticated_access only: :create
  skip_verify_authorized only: :create

  def create
    auth = request.env['omniauth.auth']
    current_user.update!(github_access_token: auth.credentials.token,
                         github_uid: auth.uid,
                         github_nickname: auth.info.nickname,
                         github_connected_date: Time.zone.now)
    flash[:success] = 'GitHub account connected successfully.'
    redirect_to session.delete(:return_to) || dashboard_path
  rescue StandardError => e
    flash[:danger] = "Failed to connect GitHub account: #{e.message}"
    redirect_to dashboard_path
  end
end
