# frozen_string_literal: true

# Controller to handle GitHub user account authorization and callbacks
class GithubIntegrationsController < ApplicationController
  def index
    authorize! with: DashboardPolicy

    @github_connected = current_user.github_connected?
  end

  # rubocop:disable Metrics/AbcSize
  def create
    authorize! with: DashboardPolicy

    current_user.authorize_github_connection(request.env['omniauth.auth'])

    flash[:success] = I18n.t('github.connected_account')
    redirect_to session.delete(:return_to) || dashboard_path
  rescue StandardError => e
    flash[:danger] = I18n.t('github.error_connecting_account', error_message: e.message)
    redirect_to dashboard_path
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    authorize! with: DashboardPolicy

    current_user.revoke_github_connection

    flash[:success] = I18n.t('github.disconnected_account')
    redirect_to dashboard_path
  rescue StandardError => e
    flash[:danger] = I18n.t('github.error_disconnecting_account', error_message: e.message)
    redirect_to github_integrations_path
  end
end
