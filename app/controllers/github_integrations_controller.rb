# frozen_string_literal: true

# Controller to handle GitHub user account authorization and callbacks
class GithubIntegrationsController < ApplicationController
  def index
    authorize! with: DashboardPolicy

    @github_connected = current_user.github_connected?
  end

  def create
    authorize! with: DashboardPolicy

    current_user.authorize_github_connection(request.env['omniauth.auth'])

    flash[:success] = 'You Github account has been successfully connected to SDR.'
    redirect_to session.delete(:return_to) || dashboard_path
  rescue StandardError => e
    flash[:danger] = "Failed to connect Github account: #{e.message}"
    redirect_to dashboard_path
  end

  def destroy
    authorize! with: DashboardPolicy

    current_user.revoke_github_connection

    flash[:success] = 'Your Github account has been disconnected from SDR.'
    redirect_to dashboard_path
  rescue StandardError => e
    flash[:danger] = "Failed to disconnect Github account: #{e.message}"
    redirect_to github_integrations_path
  end
end
